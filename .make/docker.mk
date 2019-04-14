
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

#.PHONY: docker-lint
#docker-lint: ## Run Dockerfile Lint on all dockerfiles.
#	echo "$(ROOT_DIR)"; echo "$(PWD)"
#	docker -H $(DOCKER_HOST) run -it --rm --privileged -v $(ROOT_DIR)/bin/:/root/ \
#							projectatomic/dockerfile-lint \
#                           	dockerfile_lint -p -f $(wildcard Dockerfile* */Dockerfile*) \
#							-r $(ROOT_DIR)/.dockerfile_lint/github_actions.yaml
#UPLOAD_CMD="scp $(DOCKER_FILE) $(DOCKER_PUSH)"

default: docker-help

.PHONY: docker-clean
docker-clean: ## removes previously exported build files
	@(rm -rf $(BIN_DIR)/*.tar)

.PHONY: docker-filepush
docker-filepush: ## pushes the dockerfile for the build, over to the build server
	$(shell scp $(FILES) $(DOCKER_HOST):/tmp)

.PHONY: docker-build
docker-build: docker-filepush ## builds the docker container to spec of docker file
	#@echo "Running: shell docker -H $(DOCKER_PROTO)$(DOCKER_HOST) build . -t $(IMAGE_NAME):$(RELEASE)"
	docker -H $(DOCKER_PROTO)$(DOCKER_HOST) build . -t $(IMAGE_NAME):$(RELEASE) --target utility-runner

#docker-filepush docker-build docker-save
.PHONY: docker-container-run
docker-container-run: ## provide the run command for the container to spec of files
	# docker run --rm -ti --name mu-tester-2 stelligent-mu:0.1.2 mu
	@echo "docker -H $(DOCKER_PROTO)$(DOCKER_HOST) run --rm -ti --name mu-aws-runner-agent-1-$(NAME_NAME) mu [mu specific commands, see: mu --help]"

.PHONY: docker-save
docker-save: docker-build ## saves the file of the docker build
	$( docker -H $(DOCKER_HOST) image save $(IMAGE_NAME) )

.PHONY: docker-export
docker-export: docker-filepush docker-build docker-save ## Saves docker file into tar inside bin folder
#(> $(EXPORT_FILE)
	@echo "$(EXPORT_FILE)"

.PHONY: docker-tag
docker-tag: ## assigns a tag to docker image
	tag $(IMAGE_NAME) $(DOCKER_REPO)/$(IMAGE_NAME) --no-latest

.PHONY: docker-publish
docker-publish: docker-tag ## requires docker tag, then pushes image to docker repo.
	docker push $(DOCKER_REPO)/$(IMAGE_NAME)

.PHONY: docker-help
docker-help: help