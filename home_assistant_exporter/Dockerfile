ARG BUILD_FROM
ARG EXPORTER_IMAGE="ghcr.io/craftama/home-assistant-exporter:latest"

# Prebuilt, multi-arch upstream exporter (built from images/home-assistant-exporter)
FROM ${EXPORTER_IMAGE} AS exporter

FROM $BUILD_FROM

ARG \
    BUILD_ARCH \
    BUILD_VERSION

LABEL \
    io.hass.version=${BUILD_VERSION} \
    io.hass.type="addon" \
    io.hass.arch="${BUILD_ARCH}"

# This add-on is a thin Home Assistant OS wrapper. The exporter and its Python
# dependencies are prebuilt in the GHCR image referenced by EXPORTER_IMAGE; here
# we only add the Python runtime the venv needs plus the bashio run script.
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

COPY --from=exporter /opt/venv /opt/venv
COPY --from=exporter /app /app

COPY rootfs /
RUN chmod a+x /run.sh

ENTRYPOINT []
CMD ["/run.sh"]
