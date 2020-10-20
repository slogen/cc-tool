
export DOCKER_END=cc-tool
export DEV_PACKAGES=alpine-sdk autoconf automake libtool
export BUILD_PACKAGES=libusb-dev boost-dev
export RUNTIME_PACKAGES=libusb boost-filesystem boost-regex boost-program_options



export PREFIX_DIR=/opt/$(DOCKER_END)

export DOCKER_BASE=alpine:3.12.0
export ADD_PACKAGE=apk add

EXTRADEP=Makefile
DOCKER?=docker

GIT_DESCRIBE:=$(shell git describe --always --tags --long)


all: final.docker_build

../Dockerfile:	Dockerfile.in $(EXTRADEP)
	perl -pe 's/@@([^@]+)@@/$$ENV{$$1}/g' <$(<) >$(@)

DOCKER_FLAGS=--loglevel 2
DOCKER_BUILD= $(DOCKER) build . \
	$(DOCKER_FLAGS) \
	--label 'GIT=$(GIT_DESCRIBE)'

final.docker_build: DOCKER_FLAGS += --tag='$(DOCKER_END)'
%.docker_build: DOCKER_FLAGS += --target='$(@:.docker_build=)'
%.docker_build: ../Dockerfile
	true \
	&& cd .. \
	&& $(DOCKER_BUILD)

Dockerfile: Dockerfile.in $(EXTRADEP)

DANGLING_FILTER=--filter dangling=true
clean-images:
	$(DOCKER) images --filter label='DOCKER_END=$(DOCKER_END)' --quiet \
	| xargs --no-run-if-empty $(DOCKER) image rm

dist-clean-images: DANGLING_FILTER =
dist-clean-images: clean-images

clean: dist-clean-images
dist-clean: dist-clean-images

