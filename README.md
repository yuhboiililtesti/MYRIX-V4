MYRIX

Manage Your Resources, Instantly & eXpertly

------------------------------------------------------------

OVERVIEW

MYRIX is a comprehensive Linux server management tool designed for advanced administrators who demand automation, reliability, and full control. It integrates deep service management (Plex, Minecraft, DuckDNS), system monitoring, backups, diagnostics, and security operations into a single unified CLI.

MYRIX leverages idempotency, parallel processing, and proactive healing commands to maintain optimal server health — all with an extensible modular design to future-proof your infrastructure.

------------------------------------------------------------

FEATURES

- Unified Service Management: Control Plex, Minecraft servers, DuckDNS, and more with easy commands.
- Advanced Diagnostics & Healing: Automated self-fixes, database checks, cache purges, and permission resets.
- Comprehensive Backups: Full backup, restore, and integrity verification for Plex, Minecraft, and system data.
- System Monitoring: CPU, memory, disk, network, GPU, and SMART health checks with detailed reports.
- Security & Maintenance: Firewall management, rootkit detection, password audits, and automated system updates.
- Automated Auto-fill: Customize ~/.myrix_autofill.txt to set default paths, retention policies, tokens, and more.
- Parallel & Async Operations: Heavy tasks run asynchronously to keep the server responsive.
- CI/CD Ready: Integrated git controls for safe deployment and versioning.
- Extensible Architecture: Modular design to add new services like Docker, KVM, or other virtualization tech.
- Interactive Help UI: User-friendly command listings with examples and searchable help.

------------------------------------------------------------

INSTALLATION

1. git clone https://github.com/yuhboiililtesti/MYRIX.git
2. cd MYRIX
3. chmod +x myrix.sh
4. sudo mv myrix.sh /usr/local/bin/myrix

------------------------------------------------------------

USAGE

Run 'myrix help' to see all available commands grouped by service and functionality, complete with examples.

Examples:

myrix plex_start            # Start Plex Media Server
myrix mc_backup             # Backup Minecraft server data
myrix duck_update           # Update DuckDNS IP
myrix sys_info              # Show detailed system info
myrix backup_clean          # Clean backups older than 14 days
myrix search plexmediaserver # Search drives for plexmediaserver files

------------------------------------------------------------

CONFIGURATION

MYRIX supports full auto-fill configuration via the ~/.myrix_autofill.txt file.

Example configuration file:

backup_dir=/mnt/backups/myrix
plex_data_dir=/var/lib/plexmediaserver
minecraft_data_dir=/opt/minecraft
duckdns_token=your_token_here
backup_retention_days=14

This enables MYRIX to operate fully automatically without manual input.

------------------------------------------------------------

CONTRIBUTION

Contributions are welcome! Fork the repo, create feature branches, and submit pull requests. Follow the existing code style and write tests for new features.

------------------------------------------------------------

LICENSE

MIT License — see LICENSE file for details.

------------------------------------------------------------

CONTACT

Created and maintained by yuhboiililtesti
GitHub: https://github.com/yuhboiililtesti

------------------------------------------------------------

Take full control of your Linux servers with MYRIX — Manage Your Resources, Instantly & eXpertly.
