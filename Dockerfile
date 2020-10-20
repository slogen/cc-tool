
### Build code inside docker environments, separate build and final


## https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
## https://docs.docker.com/develop/develop-images/multistage-build/

### Name what we are building:
ARG DOCKER_END=cc-tool

### Base both build and final from this base

###################### BUILD #############################
# Allow shared dev-env cache
FROM alpine:3.12.0 AS dev_env
RUN apk add alpine-sdk autoconf automake libtool
LABEL STAGE=dev_env

# Allow shared build-env in cache
FROM dev_env as build_env
RUN apk add libusb-dev boost-dev
LABEL DOCKER_END=cc-tool STAGE=build_env

# Get source for compile
FROM build_env AS bootstrap
WORKDIR /origin
COPY . .
RUN ./bootstrap
LABEL DOCKER_END=cc-tool STAGE=src

# Execute configure for compile
FROM bootstrap as configure
RUN ./configure --prefix /opt/cc-tool
LABEL DOCKER_END=cc-tool STAGE=configure

# Execute compile
FROM configure as make
RUN nproc | xargs -I % make -j%
LABEL DOCKER_END=cc-tool STAGE=make

# Install
FROM make as install
RUN make install
LABEL DOCKER_END=cc-tool STAGE=install

#######################################################################
FROM alpine:3.12.0 AS staging
WORKDIR /opt/cc-tool
COPY --from=install /opt/cc-tool /opt/cc-tool
ENTRYPOINT ["/bin/sh"]
LABEL DOCKER_END=cc-tool STAGE=staging


#######################################################################
FROM staging AS final
RUN apk add libusb boost-filesystem boost-regex boost-program_options 
ENTRYPOINT ["/bin/sh"]
LABEL DOCKER_END=cc-tool STAGE=final

