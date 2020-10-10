FROM golang:alpine AS build-env
ENV ATOM_VERSION=2.0.13
ENV ATOM_CHECKSUM=b84991a3b72ddbddb6b5a5dbf084e377db75c1766c5add48ee4469173fff2d90
ENV PACKAGES wget unzip curl make git libc-dev bash gcc linux-headers eudev-dev python2
WORKDIR /go/src/github.com/cosmos/gaia
RUN apk add --update --no-cache $PACKAGES
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