#!/bin/bash

################################################################################
# 🎮 QUICK START - HEADLESS SERVER MODE
################################################################################
# This version is fully headless and suitable for cron jobs, servers, or automation.
# ➤ No prompts. No interaction. Just plug, set DRY_RUN=false, and run.
################################################################################

# ┌───────────────────────────────┐
# │          🔧 TOGGLES           │
# └───────────────────────────────┘

DRY_RUN=false              # If true, performs a dry run (no actual file transfers)
TIMER=true                 # If true, shows the script duration at the end
ONLY_NEW=false             # If true, skips files that already exist locally
FORCE_OVERWRITES=false     # If true, overwrites existing files regardless of timestamps
IGNORE_TIMES=true          # If True, force rclone to re-evaluate all files (disables timestamp-based skip)
SKIP_VERIFIED_FILES=false  # If true, skips rechecking files that were already verified

VERIFY_POST_SYNC=true      # If true, runs post-sync verification using rclone check
USE_CHECKSUM=true          # If true, uses --checksum (hash check); if false, uses --size-only
SHOW_HASHES=true           # If true, shows hash next to each file during sync/verification
CREATE_PER_FILE_MD5=true   # If true, generates a .md5 file next to each downloaded file

MAX_RETRY_COUNT=3          # Number of times to retry a failed verification before giving up
RETENTION_DAYS=30          # How many days to keep old log files
CREATE_RETRY_SCRIPTS=true  # If true, saves failed paths into retry scripts


# ┌────────────────────────────────────┐
# │             📁 PATHS               │
# └────────────────────────────────────┘

GAMES_LOCAL_PATH="/mnt/user/Games/myrient"  # Local destination directory for all synced content
REMOTE_NAME="myrient"                       # Name of the rclone remote pointing to myrient (auto-created if missing)

# ┌────────────────────────────────────┐
# │       🚀 PERFORMANCE TUNING        │
# └────────────────────────────────────┘

STREAMS=4               # Number of parallel streams per file (multi-threaded transfers)
CUTOFF=200              # File size (in MiB) cutoff to enable multi-threaded transfers
TRANSFERS=4             # Number of files to transfer in parallel
CHECKERS=8              # Number of checkers to run in parallel (for verification)
RETRIES=10              # Number of retry attempts for transfers that fail
LOW_LEVEL_RETRIES=10    # Number of retries for low-level errors like network issues

# ┌──────────────────────────────────────────────┐
# │          🔍 INCLUDE/EXCLUDE FILTERS          │
# └──────────────────────────────────────────────┘

# Files or folders that match these patterns WILL be included in the sync.
# These typically target USA/NTSC/World region ROMs.
INCLUDES=("*USA*" "*World*" "*NTSC*")

# Files or folders that match these patterns WILL BE EXCLUDED from the sync.
# These are mostly sports titles or unwanted genres.
EXCLUDES=("*Console*" "*NFL*" "*NHL*" "*Tennis*" "*Hockey*" "*Volleyball*" "*Madden*"
  "*FootBall*" "*Golf*" "*NCAA*" "*Fishing*" "*NBA*" "*Basketball*"
  "*BaseBall*" "*MLB*" "*FIFA*" "*Soccer*" "*Bowling*")

SYSTEMS=(
# ▼ UNCOMMENT BELOW OR MAKE YOUR OWN FROM MYRIENT ▼

# -----------------------------
# 📦 INTERNET ARCHIVE COLLECTIONS
# -----------------------------

  "Internet Archive/rompacker/mame-chds-roms-extras-complete/:::Internet_Archive/rompacker/mame-chds-roms-extras-complete"
  
# -----------------------------
# 📦 OFFICIAL NO-INTRO COLLECTIONS
# -----------------------------

  "No-Intro/Arcade - PC-based/:::arcade/pc_based/roms"
  "No-Intro/Atari - 2600/:::atari/2600/roms"
  "No-Intro/Atari - 5200/:::atari/5200/roms"
  "No-Intro/Atari - 7800/:::atari/7800/roms"
  "No-Intro/Atari - 8-bit Family/:::atari/8_bit_family/roms"
#   "No-Intro/Atari - Jaguar (ABS)/:::atari/jaguar/abs"
#   "No-Intro/Atari - Jaguar (COF)/:::atari/jaguar/cof"
#   "No-Intro/Atari - Jaguar (J64)/:::atari/jaguar/j64"
#   "No-Intro/Atari - Jaguar (JAG)/:::atari/jaguar/jag"
  "No-Intro/Atari - Jaguar (ROM)/:::atari/jaguar/rom"
#   "No-Intro/Atari - Lynx (BLL)/:::atari/lynx/bll"
#   "No-Intro/Atari - Lynx (LNX)/:::atari/lynx/lnx"
#   "No-Intro/Atari - Lynx (LYX)/:::atari/lynx/lyx"
#   "No-Intro/Atari - ST/:::atari/st/roms"
#   "No-Intro/Atari - ST (Flux)/:::atari/st_flux/roms"
  "No-Intro/Coleco - ColecoVision/:::coleco/colecovision/roms"
  "No-Intro/Commodore - Amiga/:::commodore/amiga/roms"
#   "No-Intro/Commodore - Amiga (Bitstream)/:::commodore/amiga_bitstream/roms"
#   "No-Intro/Commodore - Amiga (Flux)/:::commodore/amiga_flux/roms"
  "No-Intro/Commodore - Commodore 64/:::commodore/commodore_64/roms"
  "No-Intro/Commodore - Commodore 64 (PP)/:::commodore/commodore_64/pp"
  "No-Intro/Commodore - Commodore 64 (Tapes)/:::commodore/commodore_64/tapes"
  "No-Intro/Commodore - Plus-4/:::commodore/plus_4/roms"
  "No-Intro/Commodore - VIC-20/:::commodore/vic_20/roms"
  "No-Intro/Microsoft - Xbox 360 (Digital)/:::microsoft_xbox_360/digital"
#   "No-Intro/Nintendo - Game Boy/:::nintendo/game_boy/roms"
#   "No-Intro/Nintendo - Game Boy (Private)/:::nintendo/game_boy/private_roms"
#   "No-Intro/Nintendo - Game Boy Advance/:::nintendo/game_boy_advance/roms"
#   "No-Intro/Nintendo - Game Boy Advance (Multiboot)/:::nintendo/game_boy_advance/multiboot_roms"
#   "No-Intro/Nintendo - Game Boy Advance (Play-Yan)/:::nintendo/game_boy_advance/play_yan_roms"
#   "No-Intro/Nintendo - Game Boy Color/:::nintendo/game_boy_color/roms"
#   "No-Intro/Nintendo - Kiosk Video Compact Flash (CardImage)/:::nintendo/kiosk_video_compact_flash_cardimage/roms"
#   "No-Intro/Nintendo - Kiosk Video Compact Flash (Extracted)/:::nintendo/kiosk_video_compact_flash_extracted/roms"
#   "No-Intro/Nintendo - New Nintendo 3DS (Decrypted)/:::nintendo/new_nintendo_3ds/decrypted/roms"
#   "No-Intro/Nintendo - New Nintendo 3DS (Digital) (Deprecated)/:::nintendo/new_nintendo_3ds/digital_deprecated/roms"
#   "No-Intro/Nintendo - Nintendo 3DS (Decrypted)/:::nintendo/3ds/roms"
#   "No-Intro/Nintendo - Nintendo 3DS (Digital) (CDN)/:::nintendo/3ds/digital_cdn"
#   "No-Intro/Nintendo - Nintendo 3DS (Digital) (Pre-Install)/:::nintendo/3ds/digital_pre_install"
#   "No-Intro/Nintendo - Nintendo 3DS (Encrypted)/:::nintendo/3ds/encrypted_roms"
  "No-Intro/Nintendo - Nintendo 64 (BigEndian)/:::nintendo/n64/bigendian/roms"
  "No-Intro/Nintendo - Nintendo 64 (ByteSwapped)/:::nintendo/n64/byteswapped/roms"
  "No-Intro/Nintendo - Nintendo 64DD/:::nintendo/64dd/roms"
#   "No-Intro/Nintendo - Nintendo DS (DSvision SD cards)/:::nintendo/ds/dsvision_sd_cards"
#   "No-Intro/Nintendo - Nintendo DS (Decrypted)/:::nintendo/ds/roms"
#   "No-Intro/Nintendo - Nintendo DS (Download Play)/:::nintendo/ds/download_play/roms"
#   "No-Intro/Nintendo - Nintendo DSi (Decrypted)/:::nintendo/dsi/roms"
#   "No-Intro/Nintendo - Nintendo DSi (Digital)/:::nintendo/dsi/digital"
#   "No-Intro/Nintendo - Nintendo DSi (Digital) (CDN) (Decrypted)/:::nintendo/dsi/digital_cdn_decrypted"
#   "No-Intro/Nintendo - Nintendo DSi (Encrypted)/:::nintendo/dsi/encrypted/roms"
  "No-Intro/Nintendo - Nintendo Entertainment System (Headered)/:::nintendo/nes/roms"
  "No-Intro/Nintendo - Nintendo GameCube (NPDP Carts)/:::nintendo/gamecube/npdp_carts/roms"
#   "No-Intro/Nintendo - Pokemon Mini/:::no-intro/nintendo_pokemon_mini/roms"
  "No-Intro/Nintendo - Super Nintendo Entertainment System/:::no-intro/nintendo_super_nintendo_entertainment_system/roms"
#   "No-Intro/Nintendo - Virtual Boy/:::no-intro/nintendo_virtual_boy/roms"
  "No-Intro/Nintendo - Wii (Digital) (CDN)/:::no-intro/nintendo_wii_digital_cdn/roms"
  "No-Intro/Nintendo - Wii U (Digital) (CDN)/:::no-intro/nintendo_wii_u_digital_cdn/roms"
  "No-Intro/Nintendo - amiibo/:::no-intro/nintendo_amiibo/roms"
  "No-Intro/Non-Redump - Atari - Atari Jaguar CD/:::no-intro/non_redump_atari_atari_jaguar_cd/roms"
  "No-Intro/Non-Redump - Microsoft - Xbox/:::no-intro/non_redump_microsoft_xbox/roms"
  "No-Intro/Non-Redump - Microsoft - Xbox 360/:::no-intro/non_redump_microsoft_xbox_360/roms"
  "No-Intro/Non-Redump - Nintendo - Nintendo GameCube/:::no-intro/non_redump_nintendo_nintendo_gamecube/roms"
  "No-Intro/Non-Redump - Nintendo - Wii/:::no-intro/non_redump_nintendo_wii/roms"
  "No-Intro/Non-Redump - Nintendo - Wii U/:::no-intro/non_redump_nintendo_wii_u/roms"
  "No-Intro/Non-Redump - Panasonic - 3DO Interactive Multiplayer/:::no-intro/non_redump_panasonic_3do_interactive_multiplayer/roms"
  "No-Intro/Non-Redump - Philips - CD-i/:::no-intro/non_redump_philips_cd_i/roms"
  "No-Intro/Non-Redump - Sega - Dreamcast/:::no-intro/non_redump_sega_dreamcast/roms"
  "No-Intro/Non-Redump - Sega - Sega Mega CD + Sega CD/:::no-intro/non_redump_sega_sega_mega_cd_sega_cd/roms"
  "No-Intro/Non-Redump - Sega - Sega Saturn/:::no-intro/non_redump_sega_sega_saturn/roms"
  "No-Intro/Non-Redump - Sony - PlayStation/:::no-intro/non_redump_sony_playstation/roms"
  "No-Intro/Non-Redump - Sony - PlayStation 2/:::no-intro/non_redump_sony_playstation_2/roms"
  "No-Intro/Non-Redump - Sony - PlayStation Portable/:::no-intro/non_redump_sony_playstation_portable/roms"
  "No-Intro/Sega - 32X/:::no-intro/sega_32x/roms"
  "No-Intro/Sega - Beena/:::no-intro/sega_been a/roms"
  "No-Intro/Sega - Dreamcast (Visual Memory Unit)/:::no-intro/sega_dreamcast_visual_memory_unit/roms"
  "No-Intro/Sega - Game Gear/:::no-intro/sega_game_gear/roms"
  "No-Intro/Sega - Master System - Mark III/:::no-intro/sega_master_system_mark_iii/roms"
  "No-Intro/Sega - Mega Drive - Genesis/:::no-intro/sega_mega_drive_genesis/roms"
  "No-Intro/Sega - SG-1000/:::no-intro/sega_sg_1000/roms"
  "No-Intro/Sony - PlayStation (PS one Classics) (PSN)/:::no-intro/sony_playstation_ps_one_classics_psn/roms"
  "No-Intro/Sony - PlayStation 3 (PSN) (Content)/:::no-intro/sony_playstation_3_psn_content/roms"
  "No-Intro/Sony - PlayStation 3 (PSN) (Updates)/:::no-intro/sony_playstation_3_psn_updates/roms"
  "No-Intro/Sony - PlayStation Mobile (PSN)/:::no-intro/sony_playstation_mobile_psn/roms"
  "No-Intro/Sony - PlayStation Portable (PSN) (Encrypted)/:::no-intro/sony_playstation_portable_psn_encrypted/roms"
  "No-Intro/Sony - PlayStation Vita (PSN) (Content)/:::no-intro/sony_playstation_vita_psn_content/roms"
  "No-Intro/Sony - PlayStation Vita (PSN) (Updates)/:::no-intro/sony_playstation_vita_psn_updates/roms"

# -----------------------------
# 📦 UNOFFICIAL NO-INTRO COLLECTIONS
# -----------------------------

  "No-Intro/Unofficial- Microsoft - Xbox 360 (Title Updates)/:::no-intro/unofficial_microsoft_xbox_360_title_updates/roms"
  "No-Intro/Unofficial- Nintendo - Nintendo 3DS (Digital) (Updates and DLC) (Decrypted)/:::no-intro/unofficial_nintendo_nintendo_3ds_digital_updates_and_dlc_decrypted/roms"
  "No-Intro/Unofficial- Nintendo - Wii (Digital) (Deprecated) (WAD)/:::no-intro/unofficial_nintendo_wii_digital_deprecated_wad/roms"
  "No-Intro/Unofficial- Nintendo - Wii (Digital) (Split DLC) (Deprecated) (WAD)/:::no-intro/unofficial_nintendo_wii_digital_split_dlc_deprecated_wad/roms"
  "No-Intro/Unofficial- Nintendo - Wii U (Digital) (Deprecated)/:::no-intro/unofficial_nintendo_wii_u_digital_deprecated/roms"
  "No-Intro/Unofficial- Sony - PlayStation 3 (PSN) (Decrypted)/:::no-intro/unofficial_sony_playstation_3_psn_decrypted/roms"
  "No-Intro/Unofficial- Sony - PlayStation Portable (PSN) (Decrypted)/:::no-intro/unofficial_sony_playstation_portable_psn_decrypted/roms"
  "No-Intro/Unofficial- Sony - PlayStation Portable (PSX2PSP)/:::no-intro/unofficial_sony_playstation_portable_psx2psp/roms"
  "No-Intro/Unofficial- Sony - PlayStation Vita (PSN) (Decrypted) (NoNpDrm)/:::no-intro/unofficial_sony_playstation_vita_psn_decrypted_nonpdrm/roms"
  "No-Intro/Unofficial- Sony - PlayStation Vita (PSN) (Decrypted) (VPK)/:::no-intro/unofficial_sony_playstation_vita_psn_decrypted_vpk/roms"
  "No-Intro/Unofficial- Sony - PlayStation Vita (PSVgameSD)/:::no-intro/unofficial_sony_playstation_vita_psvgamesd/roms"
  "No-Intro/Unofficial- Sony - PlayStation Vita (VPK)/:::no-intro/unofficial_sony_playstation_vita_vpk/roms"

# -----------------------------
# 📦 OFFICIAL REDUMP COLLECTIONS
# -----------------------------

#   "Redump/Arcade - Hasbro - VideoNow/:::redump/arcade_hasbro_videonow/roms"
#   "Redump/Arcade - Hasbro - VideoNow Color/:::redump/arcade_hasbro_videonow_color/roms"
#   "Redump/Arcade - Hasbro - VideoNow Jr/:::redump/arcade_hasbro_videonow_jr/roms"
#   "Redump/Arcade - Hasbro - VideoNow XP/:::redump/arcade_hasbro_videonow_xp/roms"
#   "Redump/Arcade - Konami - FireBeat/:::redump/arcade_konami_firebeat/roms"
#   "Redump/Arcade - Konami - M2/:::redump/arcade_konami_m2/roms"
#   "Redump/Arcade - Konami - System 573/:::redump/arcade_konami_system_573/roms"
#   "Redump/Arcade - Konami - System GV/:::redump/arcade_konami_system_gv/roms"
#   "Redump/Arcade - Konami - e-Amusement/:::redump/arcade_konami_e_amusement/roms"
#   "Redump/Arcade - Namco - Sega - Nintendo - Triforce/:::redump/arcade_namco_sega_nintendo_triforce/roms"
#   "Redump/Arcade - Namco - Sega - Nintendo - Triforce - GDI Files/:::redump/arcade_namco_sega_nintendo_triforce_gdi_files/roms"
#   "Redump/Arcade - Namco - System 246/:::redump/arcade_namco_system_246/roms"
#   "Redump/Arcade - Sega - Chihiro/:::redump/arcade_sega_chihiro/roms"
#   "Redump/Arcade - Sega - Chihiro - GDI Files/:::redump/arcade_sega_chihiro_gdi_files/roms"
#   "Redump/Arcade - Sega - Lindbergh/:::redump/arcade_sega_lindbergh/roms"
#   "Redump/Arcade - Sega - Naomi/:::redump/arcade_sega_naomi/roms"
#   "Redump/Arcade - Sega - Naomi - GDI Files/:::redump/arcade_sega_naomi_gdi_files/roms"
#   "Redump/Arcade - Sega - Naomi 2/:::redump/arcade_sega_naomi_2/roms"
#   "Redump/Arcade - Sega - Naomi 2 - GDI Files/:::redump/arcade_sega_naomi_2_gdi_files/roms"
#   "Redump/Arcade - Sega - RingEdge/:::redump/arcade_sega_ringedge/roms"
#   "Redump/Arcade - Sega - RingEdge 2/:::redump/arcade_sega_ringedge_2/roms"
#   "Redump/Atari - Jaguar CD Interactive Multimedia System/:::redump/atari_jaguar_cd_interactive_multimedia_system/roms"
#   "Redump/Commodore - Amiga CD/:::redump/commodore_amiga_cd/roms"
#   "Redump/Commodore - Amiga CD32/:::redump/commodore_amiga_cd32/roms"
#   "Redump/Commodore - Amiga CDTV/:::redump/commodore_amiga_cdtv/roms"
  "Redump/Microsoft - Xbox/:::redump/microsoft_xbox/iso"
  "Redump/Microsoft - Xbox 360/:::redump/microsoft_xbox_360/iso"
  "Redump/Nintendo - GameCube - NKit RVZ [zstd-19-128k]/:::redump/nintendo_gamecube/iso"
  "Redump/Nintendo - Wii - NKit RVZ [zstd-19-128k]/:::redump/nintendo_wii/iso"
  "Redump/Nintendo - Wii U - WUX/:::redump/nintendo_wii_u_wux/iso"
  "Redump/Panasonic - 3DO Interactive Multiplayer/:::redump/panasonic_3do_interactive_multiplayer/iso"
#   "Redump/Panasonic - M2/:::redump/panasonic_m2/iso"
  "Redump/Philips - CD-i/:::redump/philips_cd_i/iso"
  "Redump/PlayStation GameShark Updates/:::redump/sony_playstation/gameshark_updates"
  "Redump/Sega - Dreamcast/:::redump/sega_dreamcast/iso"
  "Redump/Sega - Dreamcast - GDI Files/:::redump/sega_dreamcast/gdi"
  "Redump/Sega - Mega CD & Sega CD/:::redump/sega_mega_cd_sega_cd/iso"
  "Redump/Sega - Saturn/:::redump/sega_saturn/iso"
  "Redump/Sony - PlayStation/:::redump/sony_playstation/iso"
#   "Redump/Sony - PlayStation - SBI Subchannels/:::redump/sony_playstation/sbi_subchannels"
  "Redump/Sony - PlayStation 2/:::redump/sony_playstation_2/iso"
  "Redump/Sony - PlayStation 3/:::redump/sony_playstation_3/iso"
  "Redump/Sony - PlayStation Portable/:::redump/sony_playstation_portable/iso"

# -----------------------------
# 📦 MISC COLLECTIONS
# -----------------------------

#   "No-Intro/Unofficial- Video Game Documents (PDF)/:::no-intro/video_game_documents_pdf/"
#   "No-Intro/Unofficial- Video Game Magazine Scans (CBZ)/:::no-intro/video_game_magazine_scans"
#   "No-Intro/Unofficial- Video Game Magazine Scans (PDF)/:::no-intro/video_game_magazine_scans"
#   "No-Intro/Unofficial- Video Game Magazine Scans (RAW)/:::no-intro/video_game_magazine_scans"
#   "Redump/Random - Covers and Scans/:::Redump/Misc/Covers_Scans"
#   "Redump/Random - Disc Tools/:::Redump/Misc/Disc_Tools"
#   "Redump/Random - Logs/:::Redump/Misc/Logs"
#   "Redump/Random - Applications/:::Redump/Misc/Apps"

)

# 💿 SYSTEM BIOS TO SYNC
# Format: "myrient_folder_path:::local_folder"
# ➤ Copy/paste entries from below to include in BIOS_PATHS

# ┌─────────────────────────────────────────────────────────────────────┐
# │                 💿 SYSTEM BIOS/FIRMWARE TO SYNC                     │
# └─────────────────────────────────────────────────────────────────────┘
# ➤ BIOS files are essential for emulation on many systems.
# ➤ Format: "myrient_folder_path:::local_folder"
#     - Left side: remote path on myrient
#     - Right side: relative destination on your system
#
# 💡 Tip: Enable the BIOS entries for any systems you've activated above.
# 💡 These are pulled from Redump’s "BIOS Images" collections.

BIOS_PATHS=(
# ▼ UNCOMMENT BELOW OR MAKE YOUR OWN FROM MYRIENT ▼
  "Internet Archive/chadmaster/mame-merged/BIOS/:::Internet_Archive/chadmaster/mame-merged/bios"
  "Redump/Nintendo - GameCube - BIOS Images/:::Redump/gamecube/bios"
  "Redump/Sony - PlayStation - BIOS Images/:::redump/sony_playstation/bios"
  "Redump/Sony - PlayStation 2 - BIOS Images/:::redump/sony_playstation_2/bios"
  "Redump/Nintendo - Wii U - Disc Keys/:::redump/nintendo_wii_u/disc_keys"
  "Redump/Microsoft - Xbox - BIOS Images/:::redump/microsoft_xbox/bios"
  "TOSEC-ISO/Sega/Dreamcast/Firmware/:::TOSEC-ISO/Sega/Dreamcast/Firmware"
  "TOSEC-ISO/Sega/Saturn/Firmware/:::TOSEC-ISO/Sega/Saturn/Firmware"
  "TOSEC-ISO/3DO/3DO Interactive Multiplayer/Firmware/:::TOSEC-ISO/3DO/3DO Interactive Multiplayer/Firmware"
  "TOSEC-ISO/Philips/CD-i/Firmware/:::TOSEC-ISO/Philips/CD-i/Firmware"
  "TOSEC-ISO/Sony/PlayStation 2/Firmware/:::TOSEC-ISO/Sony/PlayStation 2/Firmware"
  "TOSEC/Nintendo/DS/Firmware/:::TOSEC/Nintendo/DS/Firmware"
#   "TOSEC-ISO/SNK/Neo-Geo CD/Firmware/:::TOSEC-ISO/SNK/Neo-Geo CD/Firmware"
#   "TOSEC/Radica/Arcade Legends & Play TV Legends/Firmware/:::TOSEC/Radica/Arcade Legends & Play TV Legends/Firmware"
#   "TOSEC/Sharp/MZ-800 & MZ-1500/Firmware/:::TOSEC/Sharp/MZ-800 & MZ-1500/Firmware"
  "No-Intro/Sega - Dreamcast (Visual Memory Unit)/:::No-Intro/sega_dreamcast_visual_memory_unit"
)

# ┌─────────────────────────────────────────────────────────────────────┐
# │                     🔑 DISC KEYS TO SYNC                           │
# └─────────────────────────────────────────────────────────────────────┘
# ➤ Disc keys are used to decrypt disc-based games (like PS3/Wii U titles).
# ➤ Format: "myrient_folder_path:::local_folder"
#     - Left side: path on myrient
#     - Right side: relative destination on your local machine
#
# 💡 Tip: Enable the ones matching systems you plan to emulate (e.g. RPCS3 or Cemu).
# 💡 These are small files but crucial for decryption in some emulators.

DISC_KEYS_PATHS=(
  # ▼ UNCOMMENT BELOW OR MAKE YOUR OWN FROM MYRIENT ▼
  "Redump/Nintendo - Wii U - Disc Keys/:::Redump/wiiu/disk_keys"
  "Redump/Sony - PlayStation 3 - Disc Keys/:::redump/sony_playstation_3/disc_keys"
  "Redump/Sony - PlayStation 3 - Disc Keys TXT/:::redump/sony_playstation_3/disc_keys_txt"
)


# ┌──────────────────────────────────────────────┐
# │            ✅ HEADLESS MODE START            │
# └──────────────────────────────────────────────┘

# ANSI color codes for console output
GREEN="\e[32m"  # Green text (used for success messages)
RED="\e[31m"    # Red text (used for error messages)
RESET="\e[0m"   # Resets terminal text formatting to default

# Logging
LOG_FILE="$GAMES_LOCAL_PATH/sync-$(date +%F_%H-%M-%S).log"   # Timestamped log file for this sync session
VERIFIED_LOG="$GAMES_LOCAL_PATH/.verified_files.log"         # Hidden log to track already-verified files
touch "$VERIFIED_LOG"  # Ensure the verified log exists before proceeding

SECONDS=0  # Start timer (used for duration tracking with the $TIMER toggle)

# Base rclone flags used for all sync operations
RCLONE_FLAGS="--ignore-case --progress --http-no-head --create-empty-src-dirs \
--transfers=$TRANSFERS --checkers=$CHECKERS --retries=$RETRIES --multi-thread-streams=$STREAMS \
--multi-thread-cutoff=$CUTOFF --low-level-retries=$LOW_LEVEL_RETRIES --retries-sleep=10s --skip-links \
--use-server-modtime --copy-links"

# Add toggle-based rclone options dynamically
[ "$DRY_RUN" = true ] && RCLONE_FLAGS+=" --dry-run"                # Do not actually download files
[ "$ONLY_NEW" = true ] && RCLONE_FLAGS+=" --ignore-existing"       # Skip files that already exist locally
[ "$FORCE_OVERWRITES" = true ] && RCLONE_FLAGS+=" --ignore-times"  # Force overwriting regardless of timestamp
[ "$IGNORE_TIMES" = true ] && RCLONE_FLAGS+=" --ignore-times"      # Force rclone to re-evaluate all files (disables timestamp-based skip)
[ "$VERIFY_POST_SYNC" = true ] && RCLONE_FLAGS+=" --size-only"     # Use size comparison for rclone copy (initial sync)


# -----------------------------
# RCLONE INSTALL CHECK (HEADLESS)
# This block checks if rclone is installed.
# If missing, it will auto-install it (Linux only, requires curl + root).
# -----------------------------
if ! command -v rclone &> /dev/null; then
  echo "⚠ rclone not found. Attempting headless install..."

  # Check if running on Linux (required for auto-install)
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then

    # Ensure curl is available
    if command -v curl &> /dev/null; then

      # Must be root to install system-wide
      if [ "$EUID" -eq 0 ]; then
        # Attempt to download and run rclone install script silently
        curl -s https://rclone.org/install.sh | sudo bash || {
          echo "❌ rclone install failed."; exit 1;
        }
      else
        echo "❌ Must be root to install rclone. Exiting."
        exit 1
      fi
    else
      echo "❌ curl is required. Exiting."
      exit 1
    fi
  else
    echo "❌ Auto-install only supported on Linux. Exiting."
    exit 1
  fi
fi

# -----------------------------
# REMOTE CONFIG CHECK
# This block ensures the configured rclone remote exists.
# If not, it auto-creates it using the HTTP backend for Myrient.
# -----------------------------
if ! rclone listremotes | grep -q "^$REMOTE_NAME:"; then
  echo "⚠ Remote '$REMOTE_NAME' not found. Creating..."

  # Auto-create remote pointing to Myrient's base URL
  rclone config create "$REMOTE_NAME" http \
    url "https://myrient.erista.me/files/" \
    vendor "other" 2>/dev/null || {
      echo "❌ Failed to create remote. Exiting."
      exit 1
    }
fi

# -----------------------------
# SIGNAL TRAP + LOG CLEANUP
# Trap Ctrl+C / SIGTERM and cleanly exit any child jobs.
# Also prune old logs per RETENTION_DAYS.
# -----------------------------
trap 'echo -e "\n${RED}⛔ Interrupted. Exiting...${RESET}"; pkill -P $$; exit 1' SIGINT SIGTERM

mkdir -p "$GAMES_LOCAL_PATH"

# Delete old logs beyond retention period
find "$GAMES_LOCAL_PATH" -name "sync-*.log" -mtime +$RETENTION_DAYS -delete

# -----------------------------
# DISK SPACE CHECK
# Shows user how much space is available in target folder
# -----------------------------
AVAILABLE_SPACE=$(df -h "$GAMES_LOCAL_PATH" | awk 'NR==2 {print $4}')
echo -e "📥 Available disk space: $AVAILABLE_SPACE"

# -----------------------------
# RCLONE FILTER CONSTRUCTION
# Dynamically builds include/exclude filter list for rclone
#   - Blocks unwanted genres/titles (EXCLUDES)
#   - Includes only preferred regions (INCLUDES)
#   - Ignores everything else
# -----------------------------
FILTERS=()
for pattern in "${EXCLUDES[@]}"; do
  FILTERS+=(--filter="- $pattern")     # Exclude pattern
done
for pattern in "${INCLUDES[@]}"; do
  FILTERS+=(--filter="+ $pattern")     # Include pattern
done
FILTERS+=(--filter="- *")              # Exclude everything else

# -----------------------------
# 🔑 BIOS & DISC KEYS SYNC
# This section handles syncing BIOS and Disc Key files defined in BIOS_PATHS and DISC_KEYS_PATHS.
# These are critical for emulators (BIOS) or decryption (Disc Keys) to function correctly.
# -----------------------------

echo -e "\n🔑 Syncing BIOS and Disc Keys..."

# Combine BIOS and Disc Key sync targets into one array
EXTRAS=("${BIOS_PATHS[@]}" "${DISC_KEYS_PATHS[@]}")

# Track sync success/failure stats
EXTRA_SUCCESS_COUNT=0
EXTRA_FAIL_COUNT=0
FAILED_EXTRAS=()

# Loop over each BIOS or Disc Key path entry
for entry in "${EXTRAS[@]}"; do
  SRC="$REMOTE_NAME:${entry%%:::*}"        # Extract remote source path (before :::)
  DEST="$GAMES_LOCAL_PATH/${entry##*:::}"  # Extract local destination path (after :::)
  mkdir -p "$DEST"                         # Ensure local directory exists

  # Display status header for each sync block
  echo -e "\n------------------------------------------"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - 🔑 Syncing Extra: $SRC"
  echo "⬇ To: $DEST"
  echo "------------------------------------------"

  # Run rclone copy command and log output
  if ionice -c2 -n7 nice -n10 rclone copy $RCLONE_FLAGS "$SRC" "$DEST" 2>&1 | tee -a "$LOG_FILE"; then
    ((EXTRA_SUCCESS_COUNT++))  # Increment success count

    # Optional per-file .md5 generation
    if [ "$CREATE_PER_FILE_MD5" = true ]; then
      echo "🧮 Generating .md5 files in: $DEST"
      ionice -c2 -n7 nice -n10 find "$DEST" -type f ! -name "*.md5" -exec md5sum "{}" \; \
        | while read -r hash file; do
            echo "$hash  $(basename "$file")" > "$file.md5"
          done
    fi

  else
    echo -e "${RED}❌ Failed: $SRC${RESET}" | tee -a "$LOG_FILE"
    ((EXTRA_FAIL_COUNT++))     # Increment fail count
    FAILED_EXTRAS+=("$SRC")    # Save path to retry list
  fi
done

# -----------------------------
# 🔍 POST-SYNC VERIFICATION (BIOS / Disc Keys)
# If enabled, this section checks the files we just synced using rclone check.
# It retries any failed files individually up to MAX_RETRY_COUNT times.
# -----------------------------
if [ "$VERIFY_POST_SYNC" = true ]; then
  echo -e "\n🔁 Auto-retrying failed BIOS/Key verifications..."
  [ "$USE_CHECKSUM" = true ] && echo -e "🔒 Using checksum verification" || echo -e "⚡ Using size-only verification"

  # Loop over all BIOS and disc key paths again for verification
  for entry in "${EXTRAS[@]}"; do
    SRC_PATH="${entry%%:::*}"                            # Just the path portion
    SRC="$REMOTE_NAME:$SRC_PATH"                         # Full rclone source path
    DEST="$GAMES_LOCAL_PATH/${entry##*:::}"              # Local destination
    CHECK_LOG=$(mktemp)                                  # Temporary log for rclone check
    CHECK_FLAG="--size-only"
    [ "$USE_CHECKSUM" = true ] && CHECK_FLAG="--checksum"

    echo -e "🔍 Verifying $SRC vs $DEST using $CHECK_FLAG"
    ionice -c2 -n7 nice -n10 rclone check "$SRC" "$DEST" $CHECK_FLAG 2>&1 | tee -a "$LOG_FILE" | tee "$CHECK_LOG"

    # Look for verification failures in rclone check output
    grep -E 'ERROR.*(not found at destination|sizes differ|hash differ)' "$CHECK_LOG" | \
    awk -F: '{print $2}' | sed 's/^[[:space:]]*//' | while read -r FILE; do

      FILE_REL="${FILE#${SRC_PATH}/}"        # Path relative to system folder
      FILE_FULL="$SRC/$FILE_REL"             # Full path to the file on the remote

      # Skip if we've already verified it previously
      if [ "$SKIP_VERIFIED_FILES" = true ] && grep -Fxq "$FILE_FULL" "$VERIFIED_LOG"; then
        echo "✅ Skipping already verified: $FILE_REL"
        continue
      fi

      echo "🔁 Retrying: $FILE_REL"

      # Retry the failed file up to MAX_RETRY_COUNT times
      for ((i=1; i<=MAX_RETRY_COUNT; i++)); do
        echo "  🔄 Attempt $i/$MAX_RETRY_COUNT..."
        ionice -c2 -n7 nice -n10 rclone copy "$FILE_FULL" "$DEST/$(dirname "$FILE_REL")" --create-empty-src-dirs $RCLONE_FLAGS >> "$LOG_FILE" 2>&1

        echo "  🔍 Rechecking..."
        if ionice -c2 -n7 nice -n10 rclone check "$FILE_FULL" "$DEST/$FILE_REL" $CHECK_FLAG >> "$LOG_FILE" 2>&1; then
          echo "✅ Verified after retry: $FILE_REL"
          echo "$FILE_FULL" >> "$VERIFIED_LOG"  # Mark as verified
          break
        fi

        # After final failed attempt
        if (( i == MAX_RETRY_COUNT )); then
          echo -e "${RED}❌ Retry failed for $FILE_REL after $MAX_RETRY_COUNT attempts.${RESET}" | tee -a "$LOG_FILE"
        fi
      done
    done

    rm -f "$CHECK_LOG"  # Clean up temp file
  done
fi

# -----------------------------
# 🎮 ROM SYSTEMS SYNC
# This section handles syncing all selected ROM systems from the SYSTEMS array.
# It applies INCLUDE/EXCLUDE filters and tracks success/failure for each system.
# -----------------------------

echo -e "\n🎮 Syncing ROM Systems..."

# Initialize counters for sync results
SYSTEM_SUCCESS_COUNT=0
SYSTEM_FAIL_COUNT=0
FAILED_SYSTEMS=()

# Loop through each system defined in the SYSTEMS array
for system in "${SYSTEMS[@]}"; do
  SRC="$REMOTE_NAME:${system%%:::*}"             # Extract remote path before :::
  DEST="$GAMES_LOCAL_PATH/${system##*:::}"       # Extract local path after :::
  mkdir -p "$DEST"                               # Ensure destination directory exists

  # Show sync header for current system
  echo -e "\n=========================================="
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ▶ Syncing: $SRC"
  echo "⬇ To: $DEST"
  echo "=========================================="

  # Run rclone copy and log output
  if ionice -c2 -n7 nice -n10 rclone copy $RCLONE_FLAGS "${FILTERS[@]}" "$SRC" "$DEST" 2>&1 | tee -a "$LOG_FILE"; then
    ((SYSTEM_SUCCESS_COUNT++))                   # Success count

    # Optional per-file .md5 generation
    if [ "$CREATE_PER_FILE_MD5" = true ]; then
      echo "🧮 Generating .md5 files in: $DEST"
      ionice -c2 -n7 nice -n10 find "$DEST" -type f ! -name "*.md5" -exec md5sum "{}" \; \
        | while read -r hash file; do
            echo "$hash  $(basename "$file")" > "$file.md5"
          done
    fi

  else
    echo -e "${RED}❌ Failed: $SRC${RESET}" | tee -a "$LOG_FILE"
    ((SYSTEM_FAIL_COUNT++))                     # Failure count
    FAILED_SYSTEMS+=("$SRC")                    # Track for retry
  fi
done

# -----------------------------
# 🔍 POST-SYNC VERIFICATION (ROM Systems)
# If VERIFY_POST_SYNC=true, this block verifies all files in SYSTEMS
# and retries individual files that fail verification.
# -----------------------------
if [ "$VERIFY_POST_SYNC" = true ]; then
  echo -e "\n🔁 Auto-retrying failed ROM system verifications..."
  [ "$USE_CHECKSUM" = true ] && echo -e "🔒 Using checksum verification" || echo -e "⚡ Using size-only verification"

  # Loop through systems again for verification
  for system in "${SYSTEMS[@]}"; do
    SRC_PATH="${system%%:::*}"                        # Just the subpath (e.g. No-Intro/3DO Interactive Multiplayer/)
    SRC="$REMOTE_NAME:$SRC_PATH"                      # Full rclone remote path
    DEST="$GAMES_LOCAL_PATH/${system##*:::}"          # Local path
    CHECK_LOG=$(mktemp)                               # Temp file to store check output

    # Choose size or checksum for verification
    CHECK_FLAG="--size-only"
    [ "$USE_CHECKSUM" = true ] && CHECK_FLAG="--checksum"

    echo -e "🔍 Verifying $SRC vs $DEST using $CHECK_FLAG"
    ionice -c2 -n7 nice -n10 rclone check "$SRC" "$DEST" $CHECK_FLAG "${FILTERS[@]}" 2>&1 | tee -a "$LOG_FILE" | tee "$CHECK_LOG"

    # Find failed files from rclone check output
    grep -E 'ERROR.*(not found at destination|sizes differ|hash differ)' "$CHECK_LOG" | \
    awk -F: '{print $2}' | sed 's/^[[:space:]]*//' | while read -r FILE; do

      FILE_REL="${FILE#${SRC_PATH}/}"               # Path relative to system root
      FILE_FULL="$SRC/$FILE_REL"                    # Full path to individual file

      # Skip if already verified before
      if [ "$SKIP_VERIFIED_FILES" = true ] && grep -Fxq "$FILE_FULL" "$VERIFIED_LOG"; then
        echo "✅ Skipping already verified: $FILE_REL"
        continue
      fi

      echo "🔁 Retrying: $FILE_REL"

      # Retry failed file up to MAX_RETRY_COUNT
      for ((i=1; i<=MAX_RETRY_COUNT; i++)); do
        echo "  🔄 Attempt $i/$MAX_RETRY_COUNT..."
        ionice -c2 -n7 nice -n10 rclone copy "$FILE_FULL" "$DEST/$(dirname "$FILE_REL")" --create-empty-src-dirs $RCLONE_FLAGS >> "$LOG_FILE" 2>&1

        echo "  🔍 Rechecking..."
        if ionice -c2 -n7 nice -n10 rclone check "$FILE_FULL" "$DEST/$FILE_REL" $CHECK_FLAG >> "$LOG_FILE" 2>&1; then
          echo "✅ Verified after retry: $FILE_REL"
          echo "$FILE_FULL" >> "$VERIFIED_LOG"      # Save to verified log
          break
        fi

        # Final failure message after exhausting retries
        if (( i == MAX_RETRY_COUNT )); then
          echo -e "${RED}❌ Retry failed for $FILE_REL after $MAX_RETRY_COUNT attempts.${RESET}" | tee -a "$LOG_FILE"
        fi
      done
    done

    rm -f "$CHECK_LOG"  # Clean up temp check log
  done
fi

# -----------------------------
# 🔁 RETRY SCRIPT GENERATION
# If enabled, this section creates standalone .sh scripts to retry failed BIOS/disc key or ROM system syncs.
# These retry scripts can be run manually later to attempt redownloading just the failed files.
# -----------------------------

# ➤ Generate retry script for BIOS and Disc Key sync failures
if [ "$CREATE_RETRY_SCRIPTS" = true ] && [ ${#FAILED_EXTRAS[@]} -gt 0 ]; then
  RETRY_FILE="$GAMES_LOCAL_PATH/retry_failed_extras_$(date +%F_%H-%M-%S).sh"  # Create retry filename with timestamp
  echo "#!/bin/bash" > "$RETRY_FILE"        # Start with a shebang line
  chmod +x "$RETRY_FILE"                    # Make script executable

  # Add one rclone command per failed BIOS/disc key sync
  for path in "${FAILED_EXTRAS[@]}"; do
    local_path="${path#${REMOTE_NAME}:}"    # Remove remote prefix for local destination
    echo "rclone copy $RCLONE_FLAGS \"$path\" \"$GAMES_LOCAL_PATH/$local_path\"" >> "$RETRY_FILE"
  done

  echo -e "🔁 Retry script saved to: $RETRY_FILE" | tee -a "$LOG_FILE"
fi

# ➤ Generate retry script for failed ROM system syncs
if [ "$CREATE_RETRY_SCRIPTS" = true ] && [ ${#FAILED_SYSTEMS[@]} -gt 0 ]; then
  RETRY_FILE="$GAMES_LOCAL_PATH/retry_failed_systems_$(date +%F_%H-%M-%S).sh"  # Filename with timestamp
  echo "#!/bin/bash" > "$RETRY_FILE"
  chmod +x "$RETRY_FILE"

  # Add one rclone command per failed ROM system, applying filters
  for path in "${FAILED_SYSTEMS[@]}"; do
    local_path="${path#${REMOTE_NAME}:}"    # Remove remote prefix for local destination
    echo "rclone copy $RCLONE_FLAGS ${FILTERS[*]} \"$path\" \"$GAMES_LOCAL_PATH/$local_path\"" >> "$RETRY_FILE"
  done

  echo -e "🔁 Retry script saved to: $RETRY_FILE" | tee -a "$LOG_FILE"
fi

# -----------------------------
# 📋 FINAL SUMMARY OUTPUT
# This section prints a summary of the sync run to the terminal and log.
# -----------------------------
echo -e "\n📋 ${GREEN}Summary:${RESET}" | tee -a "$LOG_FILE"

# Show BIOS/Disc Key results
echo -e "🔑 BIOS/Keys: $EXTRA_SUCCESS_COUNT success, $EXTRA_FAIL_COUNT failed" | tee -a "$LOG_FILE"

# Show ROM system results
echo -e "🎮 Systems : $SYSTEM_SUCCESS_COUNT success, $SYSTEM_FAIL_COUNT failed" | tee -a "$LOG_FILE"

# Notify if retry script generation was disabled
[ "$CREATE_RETRY_SCRIPTS" = false ] && echo -e "🔁 Retry script generation is disabled." | tee -a "$LOG_FILE"

# Confirm old logs were cleaned up
echo -e "🗑️  Logs older than $RETENTION_DAYS days cleaned up" | tee -a "$LOG_FILE"

# Warn user if DRY_RUN is still enabled
[ "$DRY_RUN" = true ] && echo -e "${RED}⚠ DRY_RUN is enabled. No files were copied.\n🔜 Set DRY_RUN=false when you're ready to sync for real.${RESET}" | tee -a "$LOG_FILE"

# Print total script duration if enabled
[ "$TIMER" = true ] && echo -e "⏱️ Duration: $((SECONDS / 60))m $((SECONDS % 60))s" | tee -a "$LOG_FILE"

# Final status message
echo -e "\n🏎️ ${GREEN}All sync operations complete.${RESET}" | tee -a "$LOG_FILE"
