#!/bin/bash
# -----------------------------------------------------------------
# COLD BACKUP - FULL STACK
# Managed by Ansible - DO NOT EDIT
# Strategy: Down -> Absolute Tar -> Up
# Targets: /srv/services, /etc/wireguard, /etc/ssh
# -----------------------------------------------------------------

# --- Config ---
SERVICES_DIR="/srv/services"
BACKUP_DIR="/mnt/storage/backups"
STACK_SCRIPT="/srv/scripts/stack.sh"
TIMESTAMP=$(date +%Y%m%d_%H%M)
FILENAME="homelab_prod_$TIMESTAMP.tar.gz"
LATEST_LINK="$BACKUP_DIR/latest.tar.gz"
LOG_FILE="/var/log/homelab-backup.log"
LOCK_FILE="/tmp/homelab-backup.lock"
RETENTION_COUNT=3


# --- Requirements ---
[[ $EUID -ne 0 ]] && echo "Error: Must be run as root." && exit 1
mkdir -p "$BACKUP_DIR"

log() {
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") [$1] $2" | tee -a "$LOG_FILE"
}

# Improved cleanup function
cleanup_exit() {
    if [ -f "$LOCK_FILE" ]; then
        log "INFO" "Interruption or crash detected. Ensuring services are up..."
        $STACK_SCRIPT up -d > /dev/null 2>&1
        rm -f "$LOCK_FILE"
    fi
}
trap cleanup_exit SIGINT SIGTERM SIGQUIT

if [ -f "$LOCK_FILE" ]; then
    log "WARN" "Backup already in progress. Exiting."
    exit 1
fi
touch "$LOCK_FILE"

log "INFO" "Starting backup process"

# 1. Stop all services to freeze DBs
$STACK_SCRIPT down > /dev/null 2>&1

# 2. Create Absolute Archive
log "INFO" "Creating absolute archive: $FILENAME"
tar -czf "$BACKUP_DIR/$FILENAME" \
    --absolute-names             \
    --warning=no-file-changed    \
    --exclude="*.log"            \
    --exclude="*/tmp/*"          \
    "$SERVICES_DIR"              \
    "/etc/wireguard"             \
    "/etc/ssh"

# 3. Restore services
$STACK_SCRIPT up -d > /dev/null 2>&1

# 4. Finalize symlink and perms
ln -sf "$BACKUP_DIR/$FILENAME" "$LATEST_LINK"
chown alexis:alexis "$BACKUP_DIR/$FILENAME" "$LATEST_LINK"

# 5. Clean old backups
log "INFO" "Rotating old backups (keeping $RETENTION_COUNT)"
ls -t "$BACKUP_DIR"/homelab_prod_*.tar.gz | tail -n +$((RETENTION_COUNT + 1)) | xargs -r rm

rm -f "$LOCK_FILE"
log "INFO" "Backup process finished successfully. Size: $(du -h "$BACKUP_DIR/$FILENAME" | cut -f1)"