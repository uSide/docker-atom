FROM golang:alpine AS build-env
ENV ATOM_VERSION=2.0.5
ENV ATOM_CHECKSUM=f7b064f0779987f8a607990ffdea665259fc84383aa57faf99840d181b7894b6
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