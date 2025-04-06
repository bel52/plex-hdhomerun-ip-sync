#!/bin/bash

# === USER CONFIGURATION ===
# Full path to your Plex DVR database file
PLEX_DB="/path/to/your/com.plexapp.plugins.library.db"

# Optional backup directory (create first or change path)
BACKUP_DIR="./backups"
mkdir -p "$BACKUP_DIR"

OLD_IP="$1"
NEW_IP="$2"

# === SAFETY CHECK ===
if [ -z "$OLD_IP" ] || [ -z "$NEW_IP" ]; then
    echo "[ERROR] Usage: $0 OLD_IP NEW_IP"
    exit 1
fi

# === BACKUP BEFORE CHANGING ANYTHING ===
TIMESTAMP=$(date +%F-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/com.plexapp.plugins.library.db.bak.$TIMESTAMP"
cp "$PLEX_DB" "$BACKUP_FILE"

echo "[INFO] Backup created at $BACKUP_FILE"

# === PERFORM THE UPDATE ===
echo "[INFO] Replacing IP $OLD_IP with $NEW_IP in Plex DB..."
sed -i "s|http://$OLD_IPdevice://tv.plex.grabbers.hdhomerun/|http://$NEW_IPdevice://tv.plex.grabbers.hdhomerun/|g" "$PLEX_DB"

# === RESTART PLEX SERVER ===
# Adjust for Docker container name or native service
echo "[INFO] Restarting Plex container..."
docker restart Plex

echo "[DONE] IP updated and Plex restarted."
