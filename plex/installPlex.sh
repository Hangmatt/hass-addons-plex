#! /usr/bin/env bash
set -euo pipefail

LOG_FILE="/tmp/install_plex.log"

# Initialize log file
{
    echo "================================"
    echo "Plex Media Server Installation"
    echo "Debian 13 (Trixie) - Automated"
    echo "Started: $(date)"
    echo "================================"
    echo
} | tee "$LOG_FILE"

# Logging function that outputs to both stdout and log file
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_section() {
    echo | tee -a "$LOG_FILE"
    echo ">>> $*" | tee -a "$LOG_FILE"
}

# Check for root
if [[ $EUID -ne 0 ]]; then
    log "ERROR: This script must be run with sudo or as root"
    exit 1
fi

log_section "Verifying Debian 13 environment"
if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    log "Detected: $ID $VERSION_ID ($PRETTY_NAME)"
else
    log "ERROR: Cannot detect OS (missing /etc/os-release)"
    exit 1
fi

# Check for Debian
if [[ ! "$NAME" =~ debian ]] && [[ "$ID" != "debian" ]]; then
    log "ERROR: This script only supports Debian 13. Detected: $ID"
    exit 1
fi

# Install dependencies
log_section "Installing dependencies (curl, gnupg2)"
if ! command -v curl >/dev/null 2>&1 || ! command -v gpg >/dev/null 2>&1; then
    log "Installing missing packages..."
    apt-get update >> "$LOG_FILE" 2>&1
    apt-get install -y curl gnupg2 >> "$LOG_FILE" 2>&1
    log "Dependencies installed successfully"
else
    log "curl and gnupg2 already installed"
fi

# Remove old Plex repository files
log_section "Cleaning up old Plex repository files"
if compgen -G "/etc/apt/sources.list.d/plex*" > /dev/null 2>&1; then
    log "Found old Plex repositories, removing..."
    rm -fv /etc/apt/sources.list.d/plex* | tee -a "$LOG_FILE"
else
    log "No old Plex repositories found"
fi

# Setup new Plex repository
log_section "Setting up new Plex repository"
log "Downloading and importing Plex signing key..."
curl -LsSf https://downloads.plex.tv/plex-keys/PlexSign.v2.key | gpg --yes --dearmor -o /usr/share/keyrings/plexmediaserver.v2.gpg 2>> "$LOG_FILE"
log "Signing key installed to /usr/share/keyrings/plexmediaserver.v2.gpg"

log "Creating Plex repository entry..."
echo "deb [signed-by=/usr/share/keyrings/plexmediaserver.v2.gpg] https://repo.plex.tv/deb/ public main" | tee /etc/apt/sources.list.d/plex.list >> "$LOG_FILE"
log "Repository added: https://repo.plex.tv/deb/"

# Update package cache
log_section "Updating package cache"
apt-get update >> "$LOG_FILE" 2>&1
log "Package cache updated"

# Install Plex Media Server
log_section "Installing Plex Media Server"
log "Starting installation..."
apt-get install -y plexmediaserver >> "$LOG_FILE" 2>&1
log "Plex Media Server installed successfully"

# Final status
log_section "Installation complete"
log "Plex Media Server has been installed and configured."
log "Full log available at: $LOG_FILE"
{
    echo
    echo "Installation finished at: $(date)"
} | tee -a "$LOG_FILE"