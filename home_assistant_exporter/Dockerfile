ARG BUILD_FROM
FROM $BUILD_FROM

ARG \
    BUILD_ARCH \
    BUILD_VERSION \
    HAE_REF="master"

LABEL \
    io.hass.version=${BUILD_VERSION} \
    io.hass.type="addon" \
    io.hass.arch="${BUILD_ARCH}"

# This add-on is a thin Home Assistant OS wrapper around the upstream exporter:
#   https://github.com/cznewt/home-assistant-exporter
# It clones the app at build time and installs its dependencies into a venv.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.13 \
        python3-pip \
        python3.13-dev \
        python3.13-venv \
        build-essential \
        git && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean && \
    python3 -m venv /opt/venv && \
    git clone --depth 1 --branch "${HAE_REF}" \
        https://github.com/cznewt/home-assistant-exporter.git /app && \
    /opt/venv/bin/pip3 install --no-cache-dir -r /app/requirements.txt

COPY rootfs /

RUN chmod a+x /run.sh

ENTRYPOINT []
CMD ["/run.sh"]
