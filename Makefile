# Task runner

.PHONY: help build

.DEFAULT_GOAL := help

SHELL := /bin/bash

# http://stackoverflow.com/questions/1404796/how-to-get-the-latest-tag-name-in-current-branch-in-git
APP_VERSION := $(shell git describe --abbrev=0)

#PROJECT_NS   := apache-php
#CONTAINER_NS := apache-php
GIT_HASH     := $(shell git rev-parse --short HEAD)

ANSI_TITLE        := '\e[1;32m'
ANSI_CMD          := '\e[0;32m'
ANSI_TITLE        := '\e[0;33m'
ANSI_SUBTITLE     := '\e[0;37m'
ANSI_WARNING      := '\e[1;31m'
ANSI_OFF          := '\e[0m'

PATH_DOCS                := $(shell pwd)/docs
PATH_BUILD_CONFIGURATION := $(shell pwd)/build

TIMESTAMP := $(shell date "+%s")

help: ## Show this menu
	@echo -e $(ANSI_TITLE)apache-php$(ANSI_OFF)$(ANSI_SUBTITLE)" - A container with production ready apache + mod_php"$(ANSI_OFF)
	@echo -e "\nUsage: $ make \$${COMMAND} \n"
	@echo -e "Variables use the \$${VARIABLE} syntax, and are supplied as environment variables before the command. For example, \n"
	@echo -e "  \$$ VARIABLE="foo" make help\n"
	@echo -e $(ANSI_TITLE)Commands:$(ANSI_OFF)
	@grep -E '^[a-zA-Z_-%]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "    \033[32m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: container
container.build: ## The container to build, where ${VERSION} is the version to build.
	docker build \
	    --no-cache \
	    --build-arg="PHP_VERSION="$${VERSION} \
	    --tag="quay.io/littlemanco/apache-php:$${VERSION}-latest" \
	    .

.PHONY: container.test
container.test: ## ${VERSION} | Ensure the container boots and runs successfully.
	# Boot the container
	docker run \
	    --rm=true \
	    --name="docker-apache-php--test" \
	    --publish 80:80 \
	    --publish 443:443 \
	    --detach \
	    quay.io/littlemanco/apache-php:$${VERSION}-latest
	# Wait for the container to boot
	sleep 3
	# Verify the container works
	curl https://localhost \
	    --head \
	    --insecure
	# Cleanup
	docker stop "docker-apache-php--test"	

.PHONY: container.push
container.push:  ## Builds and pushes the container
	docker push quay.io/littlemanco/apache-php:$${VERSION}-latest
