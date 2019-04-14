REPO_URL=http://github.com/kylejeske/actions/mu
IMAGE_NAME=stelligent-mu
RELEASE=v0.1.0

include ./.make/docker.mk

default: help

.PHONY: shell-lint
shell-lint: ## lint check for all sh (build) files
	shellcheck *.sh */*.sh

.PHONY: clean
clean: docker-clean ## Clean up after the build process.

.PHONY: lint
lint: shell-lint ## Lint all of the files for this Action.

.PHONY: build
build: docker-build ## Build this Action.

.PHONY: test
test: shell-test ## Test the components of this Action.

.PHONY: publish
publish: docker-publish ## Publish this Action.

.PHONY: dev-all
dev-all: lint build test ## Lint, Build, and Test all files

.PHONY: help
help: ## help direction
	@echo "\n\tProTip:\t\n\n\tStart with command 'make build'. \n\tFurther Information at: $(REPO_URL)\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | sed 's/^[^:]*://g' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
