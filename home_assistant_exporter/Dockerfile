ARG BUILD_FROM
FROM $BUILD_FROM

ARG \
    BUILD_ARCH \
    BUILD_VERSION \
    HAE_REF="master" \
    HASS_CLIENT_VERSION="0.1.2"

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
    # Upstream requirements pin python-hass-client to a now-deleted @master branch.
    # Drop that line; the rest of requirements.txt provides a modern aiohttp/ujson.
    sed -i '/python-hass-client/d' /app/requirements.txt && \
    /opt/venv/bin/pip3 install --no-cache-dir -r /app/requirements.txt && \
    # Install hass-client with --no-deps: its 0.x pins (aiohttp==3.7.4 -> cchardet) do not
    # build on Python 3.13, but its code runs fine against the modern aiohttp above.
    /opt/venv/bin/pip3 install --no-cache-dir --no-deps "hass-client==${HASS_CLIENT_VERSION}"

COPY rootfs /

RUN chmod a+x /run.sh

ENTRYPOINT []
CMD ["/run.sh"]
