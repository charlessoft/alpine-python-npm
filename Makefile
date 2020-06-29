-include env_make

ALPINE_VER ?= 3.8
NODE_VERSION ?= 3.6
# NODE_VERSION ?= 3.6.5
PYTHON_VERSION ?= 3.6.5

NODE_VERSION ?=14.4.0

REPO = charlessoft/alpine-python-npm
NAME = alpine-python-npm-$(NODE_VERSION)

ifneq ($(STABILITY_TAG),)
    ifneq ($(TAG),latest)
        override TAG := $(TAG)-$(STABILITY_TAG)
    endif
endif

ifeq ($(TAG),)
    ifneq ($(PYTHON_DEV),)
    	TAG ?= $(NODE_VERSION)-dev
    else
        TAG ?= $(NODE_VERSION)
    endif
endif

ifneq ($(PYTHON_DEV),)
    NAME := $(NAME)-dev
endif

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg PYTHON_DEV=$(PYTHON_DEV) \
		--build-arg NODE_VERSION=$(NODE_VERSION) \
		./

test:
	IMAGE=$(REPO):$(TAG) ./test.sh

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) -e DEBUG=1 $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push
