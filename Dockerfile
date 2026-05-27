ARG GO_VERSION=1.23
ARG ALPINE_VERSION=3.20
ARG DERPER_VERSION=latest

FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS builder
ARG DERPER_VERSION
ARG TARGETOS
ARG TARGETARCH
ENV CGO_ENABLED=0 GOTOOLCHAIN=auto
RUN GOOS=${TARGETOS:-linux} GOARCH=${TARGETARCH:-amd64} \
        go install -ldflags="-s -w" tailscale.com/cmd/derper@${DERPER_VERSION} \
    && install -D "$(find /go/bin -name derper -type f | head -n1)" /out/derper

FROM alpine:${ALPINE_VERSION}
RUN apk add --no-cache ca-certificates tini

COPY --from=builder /out/derper /usr/local/bin/derper
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/derper /usr/local/bin/entrypoint.sh

VOLUME ["/var/lib/derper"]
EXPOSE 80/tcp 443/tcp 3478/udp

WORKDIR /var/lib/derper
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD []
