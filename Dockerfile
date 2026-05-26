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
RUN apk add --no-cache ca-certificates tini libcap \
    && addgroup -S derper \
    && adduser -S -G derper -H -D -h /var/lib/derper derper \
    && mkdir -p /var/lib/derper/certs /var/lib/derper/setec \
    && chown -R derper:derper /var/lib/derper

COPY --from=builder /out/derper /usr/local/bin/derper
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/derper /usr/local/bin/entrypoint.sh \
    && setcap 'cap_net_bind_service=+ep' /usr/local/bin/derper

ENV DERP_CERT_DIR=/var/lib/derper/certs \
    DERP_SECRETS_CACHE_DIR=/var/lib/derper/setec

VOLUME ["/var/lib/derper"]
EXPOSE 80/tcp 443/tcp 3478/udp

USER derper
WORKDIR /var/lib/derper
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD []
