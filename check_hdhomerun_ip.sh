#!/bin/bash

# === USER CONFIGURATION ===
# Replace with your own HDHomeRun device ID (found at http://<your-HDHR-IP>/discover.json)
HDHR_ID="REPLACE_WITH_YOUR_HDHR_ID"

# Full path to your Plex SQLite DB (used for DVR tuner configuration)
PLEX_DB="/path/to/your/com.plexapp.plugins.library.db"

# Path to the script that updates Plex's config — assumed to be in the same folder
FIX_SCRIPT="./update_plex_tuner_ip.sh"

# Set to 1 for testing (does not apply changes), 0 to make changes live
DRY_RUN=1

# === STEP 1: Scan local network for active HDHomeRun IP ===
echo "[INFO] Scanning network for HDHomeRun device ID $HDHR_ID..."
CURRENT_IP=$(for ip in $(seq 1 254); do
    curl -s --connect-timeout 1 "http://192.168.86.$ip/discover.json" | grep -q "$HDHR_ID" && echo "192.168.86.$ip" && break
done)

if [ -z "$CURRENT_IP" ]; then
    echo "[ERROR] Could not find HDHomeRun on the network."
    exit 1
fi
echo "[INFO] Found HDHomeRun on network at: $CURRENT_IP"

# === STEP 2: Find stored IPs for this HDHR device in the Plex DB ===
MATCHED_IPS=$(grep -ao "http://192\.168\.86\.[0-9]\+device://tv.plex.grabbers.hdhomerun/$HDHR_ID" "$PLEX_DB" | \
sed -E 's|http://(192\.168\.86\.[0-9]+)device://.*|\1|' | sort | uniq)

# === STEP 3: Validate which stored IP is still alive ===
STORED_IP=""
for ip in $MATCHED_IPS; do
    if curl -s --connect-timeout 1 "http://$ip/discover.json" | grep -q "$HDHR_ID"; then
        STORED_IP="$ip"
        break
    fi
done

if [ -z "$STORED_IP" ]; then
    echo "[WARN] No valid HDHomeRun IP found in Plex DB. Assuming fresh setup."
    exit 0
fi

echo "[INFO] Plex is currently using IP: $STORED_IP"

# === STEP 4: Compare and act if IPs differ ===
if [ "$CURRENT_IP" == "$STORED_IP" ]; then
    echo "[OK] Plex and HDHomeRun are in sync. No update needed."
else
    echo "[CHANGE DETECTED] Plex is using $STORED_IP but HDHomeRun is now at $CURRENT_IP"
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "[DRY RUN] Would have run: $FIX_SCRIPT $STORED_IP $CURRENT_IP"
    else
        bash "$FIX_SCRIPT" "$STORED_IP" "$CURRENT_IP"
    fi
fi
