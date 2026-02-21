ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:8.1.4
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell to bash with strict error handling
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Build arguments for version control and metadata
ARG BUILD_ARCH=amd64
ARG PLEX_VERSION=1.43.0.10492
ARG PLEX_HASH=121068a07

# Install required system dependencies for Plex setup
# curl: for downloading GPG keys and scripts
# gnupg2: for verifying and dearmoring GPG keys
# ca-certificates: for HTTPS certificate validation
# apt-transport-https: for HTTPS repository access
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg2 \
    ca-certificates \
    apt-transport-https && \

# Configure Plex Media Server repository and install
# 1. Remove any existing Plex repository files to ensure clean state
# 2. Download and import Plex GPG signing key for package verification
# 3. Add official Plex repository configuration to apt sources
# 4. Update package cache with new repository
# 5. Install Plex Media Server package
    rm -f /etc/apt/sources.list.d/plex* && \
    curl -LsSf https://downloads.plex.tv/plex-keys/PlexSign.v2.key | gpg --yes --dearmor -o /usr/share/keyrings/plexmediaserver.v2.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/plexmediaserver.v2.gpg] https://repo.plex.tv/deb/ public main" > /etc/apt/sources.list.d/plex.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends plexmediaserver=1.43.0.10492* && \

# Clean up package manager cache and temporary files to reduce image size
# Removes:
# - apt cache and update lists
# - /tmp files
# - /var/log files
# - apt lists
    apt-get -y clean && \
    rm -fr \
        /tmp/* \
        /var/{cache,log}/* \
        /var/lib/apt/lists/*

# Copy custom container runtime filesystem configuration
# Includes startup scripts, configuration templates, and service definitions
COPY rootfs /

# Declare build arguments for image metadata and labeling
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Add OCI and Home Assistant specific labels for image identification and metadata
# Labels enable automatic discovery and configuration in Home Assistant
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Franck Nijhof <frenck@addons.community>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Franck Nijhof <frenck@addons.community>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://addons.community" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
