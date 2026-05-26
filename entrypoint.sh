#!/bin/sh
set -eu

# Map DERP_* environment variables to derper CLI flags.
# Arguments passed to the container are appended after the env-derived flags,
# so they take precedence and can be used for flags not covered here.

# Accumulate args as a single shell-quoted string, applied via eval at the end.
ARGS=""

shquote() {
    # Wrap $1 in single quotes, escaping any embedded single quotes.
    printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

add_str() {
    # $1 = flag name, $2 = env var name
    eval "v=\${$2-}"
    if [ -n "${v-}" ]; then
        ARGS="$ARGS -$1=$(shquote "$v")"
    fi
}

add_bool() {
    # $1 = flag name, $2 = env var name
    # Accepts: true/false/1/0/yes/no/on/off (case-insensitive).
    eval "v=\${$2-}"
    if [ -n "${v-}" ]; then
        case "$(printf '%s' "$v" | tr '[:upper:]' '[:lower:]')" in
            1|true|yes|on)  ARGS="$ARGS -$1=true"  ;;
            0|false|no|off) ARGS="$ARGS -$1=false" ;;
            *) echo "entrypoint: invalid boolean for $2: $v" >&2; exit 2 ;;
        esac
    fi
}

add_bool dev                              DERP_DEV
add_str  a                                DERP_ADDR
add_str  http-port                        DERP_HTTP_PORT
add_str  stun-port                        DERP_STUN_PORT
add_str  c                                DERP_CONFIG_PATH
add_str  certmode                         DERP_CERT_MODE
add_str  certdir                          DERP_CERT_DIR
add_str  hostname                         DERP_HOSTNAME
add_str  acme-eab-kid                     DERP_ACME_EAB_KID
add_str  acme-eab-key                     DERP_ACME_EAB_KEY
add_str  acme-email                       DERP_ACME_EMAIL
add_bool stun                             DERP_RUN_STUN
add_bool derp                             DERP_RUN_DERP
add_str  home                             DERP_HOME
add_str  mesh-psk-file                    DERP_MESH_PSK_FILE
add_str  mesh-with                        DERP_MESH_WITH
add_str  secrets-url                      DERP_SECRETS_URL
add_str  secrets-path-prefix              DERP_SECRETS_PATH_PREFIX
add_str  secrets-cache-dir                DERP_SECRETS_CACHE_DIR
add_str  bootstrap-dns-names              DERP_BOOTSTRAP_DNS_NAMES
add_str  unpublished-bootstrap-dns-names  DERP_UNPUBLISHED_BOOTSTRAP_DNS_NAMES
add_bool verify-clients                   DERP_VERIFY_CLIENTS
add_str  verify-client-url                DERP_VERIFY_CLIENT_URL
add_bool verify-client-url-fail-open      DERP_VERIFY_CLIENT_URL_FAIL_OPEN
add_str  socket                           DERP_SOCKET
add_str  accept-connection-limit          DERP_ACCEPT_CONNECTION_LIMIT
add_str  accept-connection-burst          DERP_ACCEPT_CONNECTION_BURST
add_str  rate-config                      DERP_RATE_CONFIG
add_str  tcp-keepalive-time               DERP_TCP_KEEPALIVE_TIME
add_str  tcp-user-timeout                 DERP_TCP_USER_TIMEOUT
add_str  tcp-write-timeout                DERP_TCP_WRITE_TIMEOUT
add_bool ace                              DERP_ACE

# Push env-derived flags into $@ before any user-supplied args.
eval "set -- $ARGS \"\$@\""

# Allow dropping into a shell for debugging.
if [ "${1-}" = "sh" ] || [ "${1-}" = "/bin/sh" ]; then
    exec "$@"
fi

exec /usr/local/bin/derper "$@"
