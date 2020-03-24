FROM golang:alpine AS build-env
ENV ATOM_VERSION=2.0.7
ENV ATOM_CHECKSUM=bbdbff3d74744d9d6491135ca07a57d729a72b4136f364d5e0f4e74cf5a274c8
ENV PACKAGES wget unzip curl make git libc-dev bash gcc linux-headers eudev-dev python
WORKDIR /go/src/github.com/cosmos/gaia
RUN apk add --no-cache $PACKAGES
RUN wget https://github.com/cosmos/gaia/archive/v${ATOM_VERSION}.zip \
    && echo "${ATOM_CHECKSUM}  v${ATOM_VERSION}.zip" | sha256sum -c \
    && unzip v${ATOM_VERSION}.zip \
    && cp -r gaia-${ATOM_VERSION}/* ./
RUN make tools && make install

FROM alpine:edge
RUN apk add --update ca-certificates
WORKDIR /root
COPY --from=build-env /go/bin/gaiad /usr/bin/gaiad
COPY --from=build-env /go/bin/gaiacli /usr/bin/gaiacli
ENTRYPOINT ["gaiad"]