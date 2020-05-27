## https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
## https://docs.docker.com/develop/develop-images/multistage-build/

ARG END=cc-tool

FROM alpine as base
RUN apk update

# Possibly shared basic dev-env #######################################
FROM base AS dev
RUN apk add alpine-sdk autoconf automake libtool
LABEL STAGE=dev

FROM dev as build
RUN apk add libusb-dev boost-dev
LABEL END=cc-tool STAGE=build

# Get source for compile
FROM build AS src
WORKDIR /src
COPY . .
LABEL END=cc-tool STAGE=src

# Execute compile
FROM src as make
WORKDIR /src
RUN ./bootstrap \
    && ./configure --prefix /opt/cc-tool  \
    && nproc | xargs -I % make -j%
LABEL END=cc-tool STAGE=make

# Install
FROM make as install
WORKDIR /src
RUN make install
LABEL END=cc-tool STAGE=install

#######################################################################
FROM base AS staging
WORKDIR /opt/cc-tool
COPY --from=install /opt/cc-tool .
ENTRYPOINT ["/bin/sh"]
LABEL END=cc-tool STAGE=staging


#######################################################################
FROM staging AS final
WORKDIR /opt/cc-tool
RUN true \
    && apk add libusb boost-filesystem boost-regex boost-program_options 
ENTRYPOINT ["/bin/sh"]
LABEL END=cc-tool STAGE=final

