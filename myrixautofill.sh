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
