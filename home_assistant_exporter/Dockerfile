# Thin Home Assistant OS wrapper around the upstream exporter image
# (set as build_from in build.yaml): https://github.com/cznewt/home-assistant-exporter
# All exporter code + Python dependencies live in that prebuilt, multi-arch image;
# here we only translate add-on options into the HASS_URL / HASS_TOKEN env it reads.
ARG BUILD_FROM
FROM $BUILD_FROM

ARG \
    BUILD_ARCH \
    BUILD_VERSION

LABEL \
    io.hass.version=${BUILD_VERSION} \
    io.hass.type="addon" \
    io.hass.arch="${BUILD_ARCH}"

USER root

COPY rootfs /
RUN chmod a+x /run.sh

ENTRYPOINT []
CMD ["/run.sh"]
