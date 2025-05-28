<<<<<<< HEAD
ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:7.7.0
# hadolint ignore=DL3006
=======
ARG BUILD_FROM=ghcr.io/hassio-addons/ubuntu-base/amd64:6.2.0
# FROM ubuntu:20.04
>>>>>>> de42c4ca1cff17edfc2864682f39df04c1d7088c
FROM ${BUILD_FROM}

ARG S6_OVERLAY_VERSION=v2.1.0.0
ARG S6_OVERLAY_ARCH=aarch64
ARG PLEX_BUILD=linux-aarch64
ARG PLEX_DISTRO=debian
ARG DEBIAN_FRONTEND="noninteractive"
ENV TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8"

ENTRYPOINT ["/init"]

RUN \
<<<<<<< HEAD
    echo "deb http://deb.debian.org/debian bookworm contrib non-free" \
        >> /etc/apt/sources.list \
    && apt-get update \
    \
    && apt-get install -y --no-install-recommends \
        xmlstarlet=1.6.1-3 \
        uuid-runtime=2.38.1-5+deb12u3 \
        unrar=1:6.2.6-1+deb12u1 \
    \
    && if [ "${BUILD_ARCH}" = "aarch64" ]; then ARCH="arm64"; fi \
    && if [ "${BUILD_ARCH}" = "amd64" ]; then ARCH="amd64"; fi \
    && if [ "${BUILD_ARCH}" = "armv7" ]; then ARCH="armhf"; fi \
    \
    && curl -J -L -o /tmp/plexmediaserver.deb \
        "https://downloads.plex.tv/plex-media-server-new/1.41.7.9823-59f304c16/debian/plexmediaserver_1.41.7.9823-59f304c16_${ARCH}.deb" \
    && dpkg --install /tmp/plexmediaserver.deb \
    \
    && apt-get -y clean \
    && rm -fr \
        /tmp/* \
        /var/{cache,log}/* \
        /var/lib/apt/lists/*
=======
# Update and get dependencies
    apt-get update && \
    apt-get install -y \
      tzdata \
      curl \
      xmlstarlet \
      uuid-runtime \
      unrar \
    && \
    \
# Fetch and extract S6 overlay
    curl -J -L -o /tmp/s6-overlay-${S6_OVERLAY_ARCH}.tar.gz https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.gz && \
    tar xzf /tmp/s6-overlay-${S6_OVERLAY_ARCH}.tar.gz -C / --exclude='./bin' && \
    tar xzf /tmp/s6-overlay-${S6_OVERLAY_ARCH}.tar.gz -C /usr ./bin && \
    \
# Add user
    useradd -U -d /config -s /bin/false plex && \
    usermod -G users plex && \
    \
# Setup directories
    mkdir -p \
      /config \
      /transcode \
      /data \
    && \
    \
# Cleanup
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*
>>>>>>> de42c4ca1cff17edfc2864682f39df04c1d7088c

EXPOSE 32400/tcp 3005/tcp 8324/tcp 32469/tcp 1900/udp 32410/udp 32412/udp 32413/udp 32414/udp
VOLUME /config /transcode

ENV CHANGE_CONFIG_DIR_OWNERSHIP="true" \
    HOME="/config"

ARG TAG=beta
ARG URL=

COPY root/ /

RUN \
# Save version and install
    /installBinary.sh

HEALTHCHECK --interval=5s --timeout=2s --retries=20 CMD /healthcheck.sh || exit 1
