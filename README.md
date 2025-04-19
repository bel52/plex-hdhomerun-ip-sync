# Plex HDHomeRun IP Sync

Automatically detect and correct changes to your HDHomeRun tuner's IP address in Plex DVR. Prevents broken tuner configs and loss of DVR/guide data due to DHCP changes.

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bel52/plex-hdhomerun-ip-sync)
![GitHub last commit](https://img.shields.io/github/last-commit/bel52/plex-hdhomerun-ip-sync)
![GitHub](https://img.shields.io/github/license/bel52/plex-hdhomerun-ip-sync)

---

## 🧐 Why Use This?

Plex stores the IP address of your HDHomeRun tuner directly in its configuration database. If your HDHomeRun changes IP (e.g. after rebooting your router or device), Plex loses the connection and may disable your DVR setup.

These scripts:
- Detect when your HDHomeRun's IP changes
- Compare it to what Plex is using
- Update the Plex database if there's a mismatch
- Restart Plex to apply the fix (optional)

---

## ⚙️ Features

- Discovers your HDHomeRun device on the local network using its unique Device ID
- Checks if Plex is using the correct IP
- Optionally updates the Plex database (`.db`) to correct it
- Creates a timestamped backup before any changes
- Restarts Plex (Docker or native) to apply the update

---

## 📦 Requirements

- Linux-based system running Plex Media Server (native or in Docker)
- Bash, `grep`, `sed`, `sqlite3`
- HDHomeRun device on the same LAN
- Plex DVR already set up at least once
- Write access to Plex’s configuration volume (especially its `.db` files)

---

## 🔍 How to Find What You Need

### 🔑 HDHomeRun Device ID

Open this in a browser:

```
http://<hdhomerun-ip>/discover.json
```

Look for:

```json
"DeviceID": "10958420"
```

Copy that value and paste it into the `HDHR_ID` variable in `check_hdhomerun_ip.sh`.

---

### 📂 How to Find Your Plex DVR Database

Look for a file named:

```
com.plexapp.plugins.library.db
```

If you're using Docker, it's typically inside the Plex config volume. You can locate it with:

```bash
find /path/to/your/plex/config -name "com.plexapp.plugins.library.db"
```

Common Docker path:

```
/path/to/plex/config/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db
```

Update the `PLEX_DB` variable in **both scripts** with the full path.

---

## 🚀 Setup Steps

1. Clone the repo or download both scripts:

```bash
git clone https://github.com/YOUR_USERNAME/plex-hdhomerun-ip-sync.git
cd plex-hdhomerun-ip-sync
```

2. Open `check_hdhomerun_ip.sh` and `update_plex_tuner_ip.sh`, then edit:

| Variable       | What It Does                                             |
|----------------|----------------------------------------------------------|
| `HDHR_ID`      | Your HDHomeRun Device ID from `/discover.json`           |
| `PLEX_DB`      | Full path to your Plex `com.plexapp.plugins.library.db`  |
| `BACKUP_DIR`   | Optional. Where backups are stored (default: `./backups`)|
| `FIX_SCRIPT`   | Path to the updater script (default: `./update_plex_tuner_ip.sh`) |

3. Make both scripts executable:

```bash
chmod +x check_hdhomerun_ip.sh
chmod +x update_plex_tuner_ip.sh
```

---

## 🧪 Usage

### Dry-run mode (won’t change anything):

```bash
./check_hdhomerun_ip.sh
```

This will:
- Discover the HDHomeRun's current IP
- Compare it to what Plex is using
- Report differences but **not** change anything

### Enable live updates:

In both scripts, change:

```bash
DRY_RUN=1
```

to:

```bash
DRY_RUN=0
```

This will:
- Back up your Plex database
- Update the IP reference
- Restart the Plex container

---

## ⏰ Automate with Cron

Edit your crontab:

```bash
crontab -e
```

Add a line to check every 30 minutes:

```bash
*/30 * * * * /path/to/check_hdhomerun_ip.sh >> /var/log/plex_hdhomerun.log 2>&1
```

---

## ⚠️ Notes

- Make sure the user running the script has permission to read/write the Plex database
- If using Docker, confirm the correct container name for your Plex server (e.g., `docker restart Plex`)
- The script only modifies the IP if it detects a mismatch AND the stored IP is no longer reachable
- Always test first using `DRY_RUN=1`

---

🧼 Optional: Log Rotation
To prevent log bloat, this project includes support for log rotation using logrotate. An example configuration file is provided:
logrotate.d.plex_hdhomerun

📦 To enable it:

Copy the config file to your system’s logrotate directory:
sudo cp logrotate.d.plex_hdhomerun /etc/logrotate.d/plex_hdhomerun
⚠️ IMPORTANT: Edit the su line to match your username and group:
The file contains:

su YOUR_USERNAME_HERE YOUR_USERNAME_HERE
Update this to reflect your actual user account.
You can find your username by running:

whoami
For example:

su alex alex
Ensure the log file exists and is owned by your user:
sudo touch /var/log/plex_hdhomerun.log
sudo chown yourusername:yourusername /var/log/plex_hdhomerun.log
✅ After setup, your logs will:

Rotate daily
Keep 7 compressed backups
Prevent uncontrolled log growth

---

## 📝 License

MIT — use, fork, and improve with attribution.
