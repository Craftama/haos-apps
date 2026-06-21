ARG BUILD_FROM
FROM $BUILD_FROM

ARG \
    BUILD_ARCH \
    BUILD_VERSION \
    SALT_VERSION="3008.1"

LABEL \
    io.hass.version=${BUILD_VERSION} \
    io.hass.type="addon" \
    io.hass.arch="${BUILD_ARCH}"

# Install a pinned salt-minion from the official Salt Project (Broadcom) apt repo.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public \
        -o /etc/apt/keyrings/salt-archive-keyring.pgp && \
    curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources \
        -o /etc/apt/sources.list.d/salt.sources && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "salt-minion=${SALT_VERSION}" \
        "salt-common=${SALT_VERSION}" && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

COPY rootfs /

RUN chmod +x /run.sh /etc/cont-init.d/salt_setup.sh /etc/services.d/salt_minion/run

ENTRYPOINT []
CMD ["/run.sh"]
