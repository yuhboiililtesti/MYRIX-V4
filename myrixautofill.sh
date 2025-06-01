#!/bin/bash
#
# myrixautofill.sh - Dynamic system config auto-detection & config generator for MYRIX
#
# This script scans your Linux server environment for all key services, hardware,
# mount points, IP addresses, etc., and writes a fully populated config file
# that MYRIX can source for zero manual setup.
#
# Run periodically or before MYRIX runs to refresh config autofill.
#

CONFIG_FILE="${HOME}/.myrix_autofill.sh"

echo "Starting MYRIX autofill configuration generation..."

# Helper: detect primary network interface (ignore docker, loopback, virtual)
detect_primary_interface() {
    ip link show | grep -E '^[0-9]+:' | awk -F: '{print $2}' | \
        grep -vE 'lo|docker|veth|br-|tun|vmnet|virbr' | head -n1 | tr -d ' '
}

# Helper: detect active IPv4 address for interface
detect_ip_for_iface() {
    local iface="$1"
    ip -4 addr show "$iface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1
}

# Detect mounted drives with free space > 1GB and list mount points
detect_mounted_drives() {
    df --output=target,avail -h | awk 'NR>1 && $2 ~ /G/ && $2+0 >= 1 {print $1}'
}

# Detect installed services by systemctl
is_service_active() {
    systemctl is-active --quiet "$1"
}

# Detect Plex installation path and service name
detect_plex() {
    if is_service_active plexmediaserver; then
        echo "plexmediaserver"
    else
        # Try common plex paths
        if [ -d "/var/lib/plexmediaserver" ]; then
            echo "plexmediaserver"
        else
            echo ""
        fi
    fi
}

# Detect Minecraft PaperMC running service or jar path
detect_mc() {
    # Common PaperMC jar locations
    local jars=(
        "/opt/minecraft/papermc.jar"
        "/srv/minecraft/papermc.jar"
        "$HOME/minecraft/papermc.jar"
    )
    for jar in "${jars[@]}"; do
        if [ -f "$jar" ]; then
            echo "$jar"
            return
        fi
    done
    # Check systemctl services with 'mc' or 'minecraft'
    if systemctl list-units --type=service | grep -qE 'mc|minecraft'; then
        echo "minecraft"
    else
        echo ""
    fi
}

# Detect VirtualBox VM names
detect_vbox_vm() {
    if command -v VBoxManage &>/dev/null; then
        VBoxManage list vms | head -n1 | awk -F'"' '{print $2}'
    else
        echo ""
    fi
}

# Detect DuckDNS token and domain from environment or file (if any)
detect_duckdns() {
    # If user has ~/.duckdns_token file or environment variable
    if [ -f "$HOME/.duckdns_token" ]; then
        cat "$HOME/.duckdns_token"
    elif [ -n "$DUCKDNS_TOKEN" ]; then
        echo "$DUCKDNS_TOKEN"
    else
        echo "your_token_here"
    fi
}

detect_duckdns_domain() {
    if [ -f "$HOME/.duckdns_domain" ]; then
        cat "$HOME/.duckdns_domain"
    elif [ -n "$DUCKDNS_DOMAIN" ]; then
        echo "$DUCKDNS_DOMAIN"
    else
        echo "yourdomain.duckdns.org"
    fi
}

# Detect logs directory
detect_log_dir() {
    if [ -d "/var/log/myrix" ]; then
        echo "/var/log/myrix"
    else
        echo "/var/log"
    fi
}

# Backup directories detection or default to first large mounted drive
detect_backup_dirs() {
    local drives=($(detect_mounted_drives))
    if [ ${#drives[@]} -gt 0 ]; then
        echo "${drives[0]}/backups/plex"
        echo "${drives[0]}/backups/mc"
    else
        echo "/mnt/backups/plex"
        echo "/mnt/backups/mc"
    fi
}

# Auto-detect server IP
detect_server_ip() {
    local iface
    iface=$(detect_primary_interface)
    if [ -n "$iface" ]; then
        detect_ip_for_iface "$iface"
    else
        echo "127.0.0.1"
    fi
}

# Auto-detect Minecraft server port (default fallback)
detect_mc_port() {
    # Could scan for running java process with papermc.jar and parse port? 
    # For now fallback default
    echo "25565"
}

# Auto-detect Plex port default
detect_plex_port() {
    echo "32400"
}

# Auto-detect network interface
detect_network_iface() {
    local iface
    iface=$(detect_primary_interface)
    if [ -n "$iface" ]; then
        echo "$iface"
    else
        echo "eth0"
    fi
}

# Generate config file
generate_config() {
    echo "# MYRIX AutoFill Configuration"
    echo "# Generated on $(date)"
    echo ""
    echo "# Backup Settings"
    local backup_dirs=($(detect_backup_dirs))
    echo "PLEX_BACKUP_DIR=${backup_dirs[0]}"
    echo "MC_BACKUP_DIR=${backup_dirs[1]}"
    echo "BACKUP_RETENTION_DAYS=7"
    echo ""
    echo "# Log Settings"
    echo "LOG_DIR=$(detect_log_dir)"
    echo "LOG_RETENTION_DAYS=30"
    echo ""
    echo "# DuckDNS Settings"
    echo "DUCKDNS_TOKEN=$(detect_duckdns)"
    echo "DUCKDNS_DOMAIN=$(detect_duckdns_domain)"
    echo ""
    echo "# Git Settings"
    echo "GIT_REPO_PATH=$HOME/projects/myrepo"
    echo "GIT_BRANCH=main"
    echo ""
    echo "# VirtualBox Settings"
    echo "VBOX_VM_NAME=$(detect_vbox_vm)"
    echo "VBOX_SNAPSHOT_NAME=DailyBackup"
    echo ""
    echo "# Server Settings"
    echo "SERVER_IP=$(detect_server_ip)"
    echo "PLEX_SERVICE_NAME=$(detect_plex)"
    echo "MC_SERVICE_NAME=$(detect_mc)"
    echo ""
    echo "# Minecraft Settings"
    echo "MC_WORLD_DIR=/opt/minecraft/world"
    echo "MC_JAR_PATH=$(detect_mc)"
    echo "MC_MAX_MEMORY=4G"
    echo "MC_MIN_MEMORY=1G"
    echo "MC_PORT=$(detect_mc_port)"
    echo ""
    echo "# Plex Settings"
    echo "PLEX_CONFIG_DIR=\"/var/lib/plexmediaserver/Library/Application Support/Plex Media Server\""
    echo "PLEX_PORT=$(detect_plex_port)"
    echo ""
    echo "# Network Settings"
    echo "NETWORK_INTERFACE=$(detect_network_iface)"
    echo ""
    echo "# Additional Settings"
    echo "AUTO_REBOOT=true"
    echo "ENABLE_BACKUPS=true"
    echo "BACKUP_SCHEDULE=\"02:00\""
}

# Main logic

echo "Detecting system configuration..."
generate_config > "$CONFIG_FILE"

echo "Configuration generated and saved to: $CONFIG_FILE"
echo "Load this file in MYRIX for full auto configuration."


# === Backup Settings ===
PLEX_BACKUP_DIR=/mnt/backups/plex
MC_BACKUP_DIR=/mnt/backups/mc
SYSTEM_BACKUP_DIR=/mnt/backups/system
BACKUP_RETENTION_DAYS=14
BACKUP_SCHEDULE="02:00"            # HH:MM for daily backup cron timing
ENABLE_BACKUPS=true
BACKUP_ENCRYPTION=true             # true/false to toggle encrypted backups
BACKUP_ENCRYPTION_KEY_PATH=/root/.backup_key.pem

# === Log Settings ===
LOG_DIR=/var/log/myrix
LOG_RETENTION_DAYS=30
LOG_LEVEL=INFO                    # DEBUG, INFO, WARN, ERROR
LOG_ROTATE_SIZE=50M              # Max log file size before rotation
LOG_ARCHIVE_DIR=/var/log/myrix/archive

# === DuckDNS Settings ===
DUCKDNS_TOKEN=your_token_here
DUCKDNS_DOMAIN=yourdomain.duckdns.org
DUCKDNS_UPDATE_INTERVAL=300       # Seconds between IP updates
DUCKDNS_SCRIPT_PATH=/opt/duckdns/duck.sh

# === Git Settings ===
GIT_REPO_PATH=/home/user/projects/myrepo
GIT_BRANCH=main
GIT_PULL_STRATEGY=rebase          # merge, rebase, or none
GIT_DEPLOY_SCRIPT=/home/user/scripts/deploy.sh

# === VirtualBox Settings ===
VBOX_VM_NAME=MyVM
VBOX_SNAPSHOT_NAME=DailyBackup
VBOX_MEMORY_MB=2048
VBOX_CPUS=2
VBOX_NETWORK_ADAPTER="Bridged Adapter"
VBOX_START_MODE=headless          # gui or headless

# === Server Settings ===
SERVER_IP=192.168.1.100
SERVER_HOSTNAME=myserver.local
SERVER_ADMIN_EMAIL=admin@example.com
SSH_PORT=22
SSH_USER=admin
SSH_KEY_PATH=/home/admin/.ssh/id_rsa

# === Plex Settings ===
PLEX_SERVICE_NAME=plexmediaserver
PLEX_CONFIG_DIR="/var/lib/plexmediaserver/Library/Application Support/Plex Media Server"
PLEX_PORT=32400
PLEX_DATA_DIR=/mnt/plexdata
PLEX_TRANSCODE_DIR=/mnt/plextranscode
PLEX_CACHE_DIR=/mnt/plexcache
PLEX_MAX_BANDWIDTH=100Mbps

# === Minecraft Settings ===
MC_SERVICE_NAME=papermc
MC_WORLD_DIR=/opt/minecraft/world
MC_JAR_PATH=/opt/minecraft/papermc.jar
MC_MAX_MEMORY=4G
MC_MIN_MEMORY=1G
MC_PORT=25565
MC_RCON_PORT=25575
MC_RCON_PASSWORD=changeme
MC_AUTO_RESTART=true
MC_PLUGIN_DIR=/opt/minecraft/plugins
MC_LOG_DIR=/opt/minecraft/logs

# === Network Settings ===
NETWORK_INTERFACE=eth0
NETWORK_DNS_SERVERS="8.8.8.8 8.8.4.4"
NETWORK_GATEWAY=192.168.1.1
NETWORK_FIREWALL_ENABLED=true
NETWORK_FIREWALL_PORTS_OPEN="22 80 443 32400 25565"

# === System Maintenance Settings ===
AUTO_REBOOT=true
REBOOT_THRESHOLD_LOAD=5.0
REBOOT_AFTER_UPGRADE=true
CLEANUP_OLD_LOGS=true
CLEANUP_OLD_LOGS_DAYS=30
AUTO_UPDATE_SYSTEM=true
SYSTEM_UPDATE_SCHEDULE="03:00"    # HH:MM for daily system update cron

# === Monitoring & Alerts ===
MONITOR_CPU_THRESHOLD=80         # Percent CPU usage to trigger alert
MONITOR_MEM_THRESHOLD=80         # Percent memory usage to trigger alert
MONITOR_DISK_THRESHOLD=85        # Percent disk usage to trigger alert
ALERT_EMAILS="admin@example.com,ops@example.com"
ALERT_ENABLE=true

# === Security Settings ===
FAIL2BAN_ENABLED=true
FAIL2BAN_JAILS="sshd plex mc"
SECURITY_SCAN_SCHEDULE="Sunday 02:00"
SECURITY_SCAN_SCRIPT=/usr/local/bin/security_scan.sh

# === Miscellaneous ===
TEMP_DIR=/tmp/myrix_temp
TMP_CLEAN_SCHEDULE="daily"
DEBUG_MODE=false

# === Custom User Settings ===
USER_ENV_VARS="/etc/profile.d/custom_env.sh"

