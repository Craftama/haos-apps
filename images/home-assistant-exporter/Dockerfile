# Standalone, multi-arch image for the upstream Home Assistant Exporter.
#   source: https://github.com/cznewt/home-assistant-exporter
# Published to ghcr.io/craftama/home-assistant-exporter and consumed by the
# haos-apps `home_assistant_exporter` add-on (and any other Dockerfiles).
#
# Built on debian:trixie (python 3.13) so the venv interpreter matches the
# Home Assistant debian-base used by the add-on, allowing a plain COPY --from.

FROM debian:trixie-slim AS build

ARG HAE_REF="master"
# Upstream pins python-hass-client to a now-deleted @master branch; we install the
# library from PyPI instead. Its 0.x deps pin aiohttp 3.7.4 -> cchardet (won't build
# on Python 3.13), so it is installed --no-deps against the modern aiohttp above.
ARG HASS_CLIENT_VERSION="0.1.2"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
        python3-dev \
        build-essential \
        git \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv && \
    git clone --depth 1 --branch "${HAE_REF}" \
        https://github.com/cznewt/home-assistant-exporter.git /app && \
    sed -i '/python-hass-client/d' /app/requirements.txt && \
    /opt/venv/bin/pip install --no-cache-dir -r /app/requirements.txt && \
    /opt/venv/bin/pip install --no-cache-dir --no-deps "hass-client==${HASS_CLIENT_VERSION}"

FROM debian:trixie-slim

ENV PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:${PATH}" \
    PYTHONPATH=/app

RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/venv /opt/venv
COPY --from=build /app /app

EXPOSE 9145
ENTRYPOINT ["python", "-m", "home_assistant_exporter"]
CMD ["--web.listen-port", "9145"]
