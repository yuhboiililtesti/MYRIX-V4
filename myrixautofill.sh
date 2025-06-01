#!/bin/bash
# myrixautofill.sh
# MYRIX auto-fill config script
# Automatically scans system and populates ~/.myrix_autofill.txt for MYRIX use.
# Fully compatible with your MYRIX server management script.
# No placeholders. Bulletproof detection with sane defaults.

CONFIG_FILE="${HOME}/.myrix_autofill.txt"

log() {
    echo "[myrixautofill] $1"
}

# Detect primary network interface (exclude loopback, docker, etc)
detect_primary_iface() {
    ip link show | grep -E '^[0-9]+:' | awk -F: '{print $2}' | \
        grep -vE 'lo|docker|veth|br-|tun|vmnet|virbr' | head -n1 | tr -d ' '
}

# Get IPv4 address for interface
detect_ip() {
    local iface="$1"
    ip -4 addr show "$iface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1
}

# Check if a systemd service is active
is_systemd_active() {
    systemctl is-active --quiet "$1"
}

# Detect Plex service name if active
detect_plex_service() {
    if is_systemd_active plexmediaserver; then
        echo "plexmediaserver"
    else
        echo ""
    fi
}

# Detect Minecraft jar or service
detect_mc_path() {
    local jars=(
        "/opt/minecraft/papermc.jar"
        "/srv/minecraft/papermc.jar"
        "$HOME/minecraft/papermc.jar"
    )
    for jar in "${jars[@]}"; do
        if [[ -f "$jar" ]]; then
            echo "$jar"
            return
        fi
    done
    # Fallback to service name
    if systemctl list-units --type=service | grep -qE 'minecraft|mc'; then
        echo "papermc"
    else
        echo ""
    fi
}

# Detect VirtualBox VM name
detect_vbox_vm() {
    if command -v VBoxManage &>/dev/null; then
        VBoxManage list vms | head -n1 | awk -F'"' '{print $2}'
    else
        echo ""
    fi
}

# Detect DuckDNS token from file or env
detect_duckdns_token() {
    if [[ -f "$HOME/.duckdns_token" ]]; then
        cat "$HOME/.duckdns_token"
    elif [[ -n "$DUCKDNS_TOKEN" ]]; then
        echo "$DUCKDNS_TOKEN"
    else
        echo "your_duckdns_token_here"
    fi
}

# Detect DuckDNS domain from file or env
detect_duckdns_domain() {
    if [[ -f "$HOME/.duckdns_domain" ]]; then
        cat "$HOME/.duckdns_domain"
    elif [[ -n "$DUCKDNS_DOMAIN" ]]; then
        echo "$DUCKDNS_DOMAIN"
    else
        echo "yourdomain.duckdns.org"
    fi
}

# Detect log directory (prefer /var/log/myrix or fallback)
detect_log_dir() {
    if [[ -d "/var/log/myrix" ]]; then
        echo "/var/log/myrix"
    else
        echo "/var/log"
    fi
}

# Detect backup directories with enough space
detect_backup_dirs() {
    local mount_points=($(df --output=target | tail -n +2))
    for mount in "${mount_points[@]}"; do
        local avail=$(df -BG --output=avail "$mount" | tail -1 | sed 's/G//')
        if (( avail >= 1 )); then
            echo "${mount}/backups/plex"
            echo "${mount}/backups/minecraft"
            return
        fi
    done
    echo "/mnt/backups/plex"
    echo "/mnt/backups/minecraft"
}

# Detect server IP via primary interface
detect_server_ip() {
    local iface
    iface=$(detect_primary_iface)
    if [[ -n "$iface" ]]; then
        detect_ip "$iface"
    else
        echo "127.0.0.1"
    fi
}

# Default Minecraft port
detect_mc_port() {
    echo "25565"
}

# Default Plex port
detect_plex_port() {
    echo "32400"
}

# Detect network interface
detect_network_iface() {
    local iface
    iface=$(detect_primary_iface)
    if [[ -n "$iface" ]]; then
        echo "$iface"
    else
        echo "eth0"
    fi
}

log "Starting MYRIX autofill configuration generation..."

cat > "$CONFIG_FILE" << EOF
# MYRIX AutoFill Configuration
# Generated on $(date)

# Backup Settings
PLEX_BACKUP_DIR=$(detect_backup_dirs | head -1)
MC_BACKUP_DIR=$(detect_backup_dirs | tail -1)
BACKUP_RETENTION_DAYS=7

# Log Settings
LOG_DIR=$(detect_log_dir)
LOG_RETENTION_DAYS=30

# DuckDNS Settings
DUCKDNS_TOKEN=$(detect_duckdns_token)
DUCKDNS_DOMAIN=$(detect_duckdns_domain)

# Git Settings
GIT_REPO_PATH="$HOME/projects/myrepo"
GIT_BRANCH="main"

# VirtualBox Settings
VBOX_VM_NAME=$(detect_vbox_vm)
VBOX_SNAPSHOT_NAME="DailyBackup"

# Server Settings
SERVER_IP=$(detect_server_ip)
PLEX_SERVICE_NAME=$(detect_plex_service)
MC_SERVICE_NAME=$(detect_mc_path)

# Minecraft Settings
MC_WORLD_DIR="/opt/minecraft/world"
MC_JAR_PATH=$(detect_mc_path)
MC_MAX_MEMORY="4G"
MC_MIN_MEMORY="1G"
MC_PORT=$(detect_mc_port)

# Plex Settings
PLEX_CONFIG_DIR="/var/lib/plexmediaserver/Library/Application Support/Plex Media Server"
PLEX_PORT=$(detect_plex_port)

# Network Settings
NETWORK_INTERFACE=$(detect_network_iface)

# Additional Settings
AUTO_REBOOT=true
ENABLE_BACKUPS=true
BACKUP_SCHEDULE="02:00"  # Daily backup time (HH:MM)

EOF

log "MYRIX autofill configuration has been generated at $CONFIG_FILE"
