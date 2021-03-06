SHELL := /bin/bash
VERSION ?= latest

# The directory of this file
DIR := $(shell echo $(shell cd "$(shell  dirname "${BASH_SOURCE[0]}" )" && pwd ))

IMAGE_NAME ?= ps1337/radare2-docker
CONTAINER_NAME ?= radare2

# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# DOCKER TASKS
# Build the container
build: ## Build the container
	docker build --rm -t $(IMAGE_NAME) .

build-nc: ## Build the container without caching
	docker build --rm --no-cache -t $(IMAGE_NAME) .

run: ## Run container
	touch $(DIR)/radare2rc && \
	mkdir -p $(DIR)/r2-config && \
	mkdir -p $(DIR)/sharedFolder && \
	xhost +local:root && # Allow X forwarding \
	sudo docker run \
	-it \
	--name $(CONTAINER_NAME) \
	--cap-drop=ALL  \
	--cap-add=SYS_PTRACE \
	-e DISPLAY=$DISPLAY \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	-v $(DIR)/sharedFolder:/var/sharedFolder \
	-v $(DIR)/radare2rc:/home/r2/.radare2rc \
	-v $(DIR)/r2-config:/home/r2/.config/radare2 \
	-v $(DIR)/workdir:/home/r2/workdir \
	$(IMAGE_NAME):$(VERSION)

stop: ## Stop a running container
	docker stop $(CONTAINER_NAME)

remove: ## Remove a (running) container
	docker rm -f $(CONTAINER_NAME)

remove-image-force: ## Remove the latest image (forced)
	docker rmi -f $(IMAGE_NAME):$(VERSION)
