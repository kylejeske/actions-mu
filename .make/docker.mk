DOCKER_PROTO="ssh://"
CURRENT_DIR=$(shell basename $(PWD))
DOCKER_FILES="Dockerfile"
DOCKER_HOST="192.168.1.116"
DOCKER_PUSH="$(DOCKER_HOST):/tmp"
FILES=$(shell for file in `ls Dockerfile entrypoint.sh`;do echo $$file; done)
ROOT_DIR=$("..")
BIN_DIR="./bin"
RELEASE="0.1.2"
IMAGE_NAME=$(shell basename $(CURDIR))
EXPORT_FILE="$(BIN_DIR)/build-$(IMAGE_NAME)-$(RELEASE)-image.tar"
BUILD_CMD="docker -H $(DOCKER_PROTO)$(DOCKER_HOST) build . -t $(IMAGE_NAME):$(RELEASE) --no-cache "

default: docker-help

.PHONY: docker-clean
docker-clean: ## removes previously exported build files
	@(rm -rf $(BIN_DIR)/*.tar)

.PHONY: docker-windows-clean
docker-windows-clean: ## removes return (^M) from non-windows files, edited in windows.
	$(shell for file in `ls Dockerfile entrypoint.sh`; do sed -i -e "s/\r//g" $$file; done)

.PHONY: docker-filepush
docker-filepush: docker-windows-clean ## pushes the dockerfile for the build, over to the build server
	$(shell scp $(FILES) $(DOCKER_HOST):/tmp)

.PHONY: docker-build
docker-build: docker-windows-clean docker-filepush ## builds the docker container to spec of docker file
	#@echo "Running: shell docker -H $(DOCKER_PROTO)$(DOCKER_HOST) build . -t $(IMAGE_NAME):$(RELEASE)"
	docker -H $(DOCKER_PROTO)$(DOCKER_HOST) build . -t $(IMAGE_NAME):$(RELEASE) --target utility-runner

#docker-filepush docker-build docker-save
.PHONY: docker-run
docker-container-run: ## provide the run command for the container to spec of files
	# docker run --rm -ti --name mu-tester-2 stelligent-mu:0.1.2 mu
	#@echo "docker -H $(DOCKER_PROTO)$(DOCKER_HOST) run --rm -ti --name mu-aws-runner-agent-1-$(NAME_NAME) mu [mu specific commands, see: mu --help]"
	@echo "Running: docker -H $(DOCKER_PROTO)$(DOCKER_HOST) run --rm -ti --name mu-runner-agent-$(IMAGE_NAME) $(IMAGE_NAME):$(RELEASE) mu"
	docker -H $(DOCKER_PROTO)$(DOCKER_HOST) run --rm -ti --name mu-runner-agent-$(IMAGE_NAME) $(IMAGE_NAME):$(RELEASE) mu

.PHONY: docker-save
docker-save: docker-build ## saves the file of the docker build
	docker -H $(DOCKER_HOST) image save $(IMAGE_NAME)

.PHONY: docker-export
docker-export: docker-filepush docker-build ## Saves docker file into tar inside bin folder
	docker -H $(DOCKER_PROTO)$(DOCKER_HOST) image save $(IMAGE_NAME) > $(EXPORT_FILE)

.PHONY: docker-import
docker-import: ## imports a saved tar file from a remote machine to be run locally (a way to bypass having to send dockerfiles outside of the network)
	docker image load -i $(EXPORT_FILE)

.PHONY: docker-tag
docker-tag: ## assigns a tag to docker image
	tag $(IMAGE_NAME) $(DOCKER_REPO)/$(IMAGE_NAME) --no-latest

.PHONY: docker-publish
docker-publish: docker-tag ## requires docker tag, then pushes image to docker repo.
	docker push $(DOCKER_REPO)/$(IMAGE_NAME)

.PHONY: docker-help
docker-help: help