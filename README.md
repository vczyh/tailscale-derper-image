# tailscale-derper-image

A container image for [Tailscale](https://tailscale.com)'s [DERP](https://tailscale.com/kb/1232/derp-servers) relay (`tailscale.com/cmd/derper`).

The image is a transparent wrapper around the upstream `derper` binary — every CLI flag is exposed as a `DERP_*` environment variable, and any extra arguments passed to `docker run` are forwarded to `derper` unchanged.



## Ports

| Port | Proto | Purpose |
|------|-------|---------|
| 80   | TCP   | HTTP (ACME challenge, redirect) |
| 443  | TCP   | HTTPS / DERP relay |
| 3478 | UDP   | STUN |

## Configuration

Every `derper` flag has a matching `DERP_*` env var. Booleans accept `true`/`false`/`1`/`0`/`yes`/`no`/`on`/`off`.

| Env var | Flag | Notes |
|---|---|---|
| `DERP_DEV` | `-dev` | localhost dev mode, self-signed cert |
| `DERP_ADDR` | `-a` | HTTP/HTTPS listen address |
| `DERP_HTTP_PORT` | `-http-port` | set to `-1` to disable |
| `DERP_STUN_PORT` | `-stun-port` | |
| `DERP_CONFIG_PATH` | `-c` | node key file, auto-created |
| `DERP_CERT_MODE` | `-certmode` | `manual`, `letsencrypt`, `gcp` |
| `DERP_CERT_DIR` | `-certdir` | cert storage; for `manual` mode, put `<hostname>.crt` and `<hostname>.key` here |
| `DERP_HOSTNAME` | `-hostname` | TLS hostname (must resolve to this host for ACME) |
| `DERP_ACME_EAB_KID` | `-acme-eab-kid` | ACME External Account Binding key ID |
| `DERP_ACME_EAB_KEY` | `-acme-eab-key` | ACME EAB HMAC key (base64) |
| `DERP_ACME_EMAIL` | `-acme-email` | ACME contact email |
| `DERP_RUN_STUN` | `-stun` | run STUN server |
| `DERP_RUN_DERP` | `-derp` | run DERP server |
| `DERP_HOME` | `-home` | what to serve at `/` |
| `DERP_MESH_PSK_FILE` | `-mesh-psk-file` | path to mesh pre-shared key |
| `DERP_MESH_WITH` | `-mesh-with` | comma-separated peers to mesh with |
| `DERP_SECRETS_URL` | `-secrets-url` | SETEC server URL |
| `DERP_SECRETS_PATH_PREFIX` | `-secrets-path-prefix` | |
| `DERP_SECRETS_CACHE_DIR` | `-secrets-cache-dir` | |
| `DERP_BOOTSTRAP_DNS_NAMES` | `-bootstrap-dns-names` | |
| `DERP_UNPUBLISHED_BOOTSTRAP_DNS_NAMES` | `-unpublished-bootstrap-dns-names` | |
| `DERP_VERIFY_CLIENTS` | `-verify-clients` | requires `tailscaled` socket on host |
| `DERP_VERIFY_CLIENT_URL` | `-verify-client-url` | admission controller URL |
| `DERP_VERIFY_CLIENT_URL_FAIL_OPEN` | `-verify-client-url-fail-open` | |
| `DERP_SOCKET` | `-socket` | alt path to tailscaled socket |
| `DERP_ACCEPT_CONNECTION_LIMIT` | `-accept-connection-limit` | rate limit for new conns |
| `DERP_ACCEPT_CONNECTION_BURST` | `-accept-connection-burst` | |
| `DERP_RATE_CONFIG` | `-rate-config` | JSON rate limit config file |
| `DERP_TCP_KEEPALIVE_TIME` | `-tcp-keepalive-time` | |
| `DERP_TCP_USER_TIMEOUT` | `-tcp-user-timeout` | |
| `DERP_TCP_WRITE_TIMEOUT` | `-tcp-write-timeout` | `0` disables |
| `DERP_ACE` | `-ace` | experimental embedded ACE server |

Flags not covered by an env var can be passed directly:

## Building locally

```bash
docker build -t derper .

# Pin a specific upstream version
docker build --build-arg DERPER_VERSION=v1.98.3 -t derper:1.98.3 .

# Cross-build
docker buildx build --platform linux/amd64,linux/arm64 -t derper:latest .
```
