# 📦 Myrient ROM Sync Script

This script allows you to selectively sync ROMs, BIOS files, and disc keys from the [myrient.erista.me](https://myrient.erista.me/files/) archive using `rclone`. It's designed to be plug-and-play, fully self-contained, and easy to customize.

---

## 🚀 Features

- Auto-installs `rclone` on Linux (if missing)
- Auto-configures the `myrient` remote
- Download filters by region and genre (e.g., USA/World/NTSC only)
- Parallel and multi-threaded transfers for faster syncing
- Optional post-sync verification with retries
- Generates retry scripts for failed transfers
- Logging and retention controls
- Fully configurable from within the script

---

## 🔧 Configuration

Before running the script, open it in a text editor and configure the following sections:

### 1. Paths
```bash
GAMES_LOCAL_PATH="/your/destination/path"  # Where synced files will be saved
REMOTE_NAME="myrient"                      # Rclone remote name (usually leave as-is)
```

### 2. Toggles
Enable/disable behaviors:
```bash
DRY_RUN=true           # Set to false to actually sync files
VERIFY_POST_SYNC=true # Runs rclone check after syncing
USE_CHECKSUM=false    # Use checksums for verification instead of file size
```

### 3. ROM Systems
Uncomment the ROM systems you want to sync from the `SYSTEMS` array. Example:
```bash
SYSTEMS=(
  "No-Intro/Nintendo - Game Boy Advance/:::no-intro/nintendo_gba/roms"
)
```

### 4. BIOS and Disc Keys
Enable the needed entries for your systems:
```bash
BIOS_PATHS=(
  "Redump/Sony - PlayStation - BIOS Images:::Redump/psx/bios"
)

DISC_KEYS_PATHS=(
  "Redump/Nintendo - Wii U - Disc Keys:::Redump/wiiu/keys"
)
```

### 5. Filters (optional)
Include only ROMs from certain regions and exclude unwanted genres:
```bash
INCLUDES=("*USA*" "*World*" "*NTSC*")
EXCLUDES=("*NFL*" "*Soccer*" "*Golf*" ...)
```

---

## ✅ Usage

### Linux / macOS
```bash
chmod +x sync-roms.sh
./sync-roms.sh
```

### First Run
- On the first run, it will install `rclone` (Linux only) if needed.
- It will also auto-create a remote named `myrient` pointing to the archive.
- With `DRY_RUN=true`, nothing is actually downloaded. Set to `false` when you're ready.

---

## 📁 Output

- All synced files are saved under the `GAMES_LOCAL_PATH` structure.
- Logs are saved as: `sync-YYYY-MM-DD_HH-MM-SS.log`
- Verified file hashes are tracked in `.verified_files.log`
- Retry scripts are auto-generated if enabled (e.g., `retry_failed_systems_*.sh`)

---

## 🧼 Log Management

Old logs older than the number of `RETENTION_DAYS` will be automatically deleted.

---

## ❗ Notes

- The script supports filters, but they are basic string matches — refine them for better control.
- Post-sync verification adds overhead but ensures integrity.
- Some systems (like Wii U or PS3) require both BIOS and disc key files for emulators to work.

---

## 🙏 Credits

- [Myrient Archive](https://myrient.erista.me/files/)
- [rclone](https://rclone.org/)

---

## 📬 Questions or Issues?
Feel free to tweak, fork, and share improvements. This script is designed for convenience, safety, and flexibility.

Game on! 🎮

