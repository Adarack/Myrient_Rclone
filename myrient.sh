#!/bin/bash

################################################################################
# 🎮 QUICK START - CONFIGURE BEFORE RUNNING
################################################################################
# 1. This script will auto-install rclone (Linux only) and set up the myrient remote
# 2. Adjust GAMES_LOCAL_PATH to your desired local destination
# 3. Toggle DRY_RUN to false once you're ready to download for real
# 4. Add or remove systems/BIOS/keys in the lists below as needed
################################################################################

# ┌───────────────────────────────┐
# │          🔧 TOGGLES           │
# └───────────────────────────────┘

DRY_RUN=true               # If true, performs a dry run (no actual file transfers)
TIMER=true                 # If true, shows the script duration at the end
ONLY_NEW=false             # If true, skips files that already exist locally
RCLONE_CHECK=false         # If true, forces rclone to recheck existing files during sync
FORCE_OVERWRITES=false     # If true, overwrites existing files regardless of timestamps
VERIFY_POST_SYNC=true      # If true, runs post-sync verification using rclone check
USE_CHECKSUM=false         # If true, uses --checksum (hash check); if false, uses --size-only
SKIP_VERIFIED_FILES=true   # If true, skips rechecking files that were already verified
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
TRANSFERS=8             # Number of files to transfer in parallel
CHECKERS=4              # Number of checkers to run in parallel (for verification)
RETRIES=10              # Number of retry attempts for transfers that fail
LOW_LEVEL_RETRIES=10    # Number of retries for low-level errors like network issues


# ┌──────────────────────────────────────────────┐
# │           🔍 INCLUDE/EXCLUDE FILTERS          │
# └──────────────────────────────────────────────┘

# Files or folders that match these patterns WILL be included in the sync.
# These typically target USA/NTSC/World region ROMs.
INCLUDES=(
  "*USA*"     # Include anything with "USA" in the name
  "*World*"   # Include anything with "World" in the name
  "*NTSC*"    # Include anything labeled "NTSC" (North American format)
)

# Files or folders that match these patterns WILL BE EXCLUDED from the sync.
# These are mostly sports titles or unwanted genres.
EXCLUDES=(
  "*Console*" "*NFL*" "*NHL*" "*Tennis*" "*Hockey*" "*Volleyball*" "*Madden*"
  "*FootBall*" "*Golf*" "*NCAA*" "*Fishing*" "*NBA*" "*Basketball*"
  "*BaseBall*" "*MLB*" "*FIFA*" "*Soccer*" "*Bowling*"
)

# ┌─────────────────────────────────────────────────────────────────────┐
# │                    🎮 ROM SYSTEMS TO SYNC                           │
# └─────────────────────────────────────────────────────────────────────┘
# ➤ Enable systems by uncommenting their respective lines below.
# ➤ Format: "myrient_folder_path:::local_folder"
#     - Left side: path on the myrient remote
#     - Right side: relative destination path on your local drive
#
# 💡 Tip: You can mix-and-match any systems from official, unofficial, and source collections.
# 💡 Use the INCLUDES/EXCLUDES section to further filter by region or genre.

SYSTEMS=(
# ▼ UNCOMMENT BELOW OR MAKE YOUR OWN FROM MYRIENT ▼

# -----------------------------
# 📦 OFFICIAL NO-INTRO COLLECTIONS
# -----------------------------
  
  "No-Intro/3DO Interactive Multiplayer/:::no-intro/3do/roms"
  # "No-Intro/Amstrad - CPC/:::no-intro/amstrad_cpc/roms"
  # "No-Intro/Amstrad - GX4000/:::no-intro/amstrad_gx4000/roms"
  # "No-Intro/Apple - Macintosh/:::no-intro/apple_macintosh/roms"
  # "No-Intro/Apple - Pippin/:::no-intro/apple_pippin/roms"
  # "No-Intro/Atari - 2600/:::no-intro/atari_2600/roms"
  # "No-Intro/Atari - 5200/:::no-intro/atari_5200/roms"
  # "No-Intro/Atari - 7800/:::no-intro/atari_7800/roms"
  # "No-Intro/Atari - Jaguar/:::no-intro/atari_jaguar/roms"
  # "No-Intro/Atari - Lynx/:::no-intro/atari_lynx/roms"
  # "No-Intro/Atari - ST/:::no-intro/atari_st/roms"
  # "No-Intro/Bandai - WonderSwan/:::no-intro/bandai_wonderswan/roms"
  # "No-Intro/Bandai - WonderSwan Color/:::no-intro/bandai_wonderswan_color/roms"
  # "No-Intro/Coleco - ColecoVision/:::no-intro/coleco_colecovision/roms"
  # "No-Intro/Commodore - Amiga/:::no-intro/commodore_amiga/roms"
  # "No-Intro/Commodore - C64/:::no-intro/commodore_c64/roms"
  # "No-Intro/Commodore - Plus-4/:::no-intro/commodore_plus4/roms"
  # "No-Intro/Commodore - VIC-20/:::no-intro/commodore_vic20/roms"
  # "No-Intro/Emerson - Arcadia 2001/:::no-intro/emerson_arcadia_2001/roms"
  # "No-Intro/Fairchild - Channel F/:::no-intro/fairchild_channel_f/roms"
  # "No-Intro/Fujitsu - FM-7/:::no-intro/fujitsu_fm7/roms"
  # "No-Intro/Fujitsu - FM Towns/:::no-intro/fujitsu_fm_towns/roms"
  # "No-Intro/IBM - PC/:::no-intro/ibm_pc/roms"
  # "No-Intro/Magnavox - Odyssey2/:::no-intro/magnavox_odyssey2/roms"
  # "No-Intro/Mattel - Intellivision/:::no-intro/mattel_intellivision/roms"
  # "No-Intro/Microsoft - MSX/:::no-intro/microsoft_msx/roms"
  # "No-Intro/Microsoft - MSX2/:::no-intro/microsoft_msx2/roms"
  # "No-Intro/Microsoft - Xbox/:::no-intro/microsoft_xbox/roms"
  # "No-Intro/Microsoft - Xbox 360/:::no-intro/microsoft_xbox_360/roms"
  # "No-Intro/NEC - PC Engine - TurboGrafx 16/:::no-intro/nec_pc_engine/roms"
  # "No-Intro/NEC - PC Engine CD - TurboGrafx CD/:::no-intro/nec_pc_engine_cd/roms"
  # "No-Intro/NEC - PC-FX/:::no-intro/nec_pcfx/roms"
  # "No-Intro/Nintendo - Famicom Disk System/:::no-intro/nintendo_famicom_disk_system/roms"
  # "No-Intro/Nintendo - Game Boy/:::no-intro/nintendo_game_boy/roms"
  # "No-Intro/Nintendo - Game Boy Advance/:::no-intro/nintendo_game_boy_advance/roms"
  # "No-Intro/Nintendo - Game Boy Color/:::no-intro/nintendo_game_boy_color/roms"
  # "No-Intro/Nintendo - GameCube/:::no-intro/nintendo_gamecube/roms"
  # "No-Intro/Nintendo - Nintendo 64/:::no-intro/nintendo_n64/roms"
  # "No-Intro/Nintendo - Nintendo DS/:::no-intro/nintendo_ds/roms"
  # "No-Intro/Nintendo - Nintendo Entertainment System/:::no-intro/nintendo_nes/roms"
  # "No-Intro/Nintendo - Pokemon Mini/:::no-intro/nintendo_pokemon_mini/roms"
  # "No-Intro/Nintendo - Super Nintendo Entertainment System/:::no-intro/nintendo_snes/roms"
  # "No-Intro/Nintendo - Virtual Boy/:::no-intro/nintendo_virtual_boy/roms"
  # "No-Intro/Nintendo - Wii/:::no-intro/nintendo_wii/roms"
  # "No-Intro/Nintendo - Wii U/:::no-intro/nintendo_wii_u/roms"
  # "No-Intro/Panasonic - 3DO/:::no-intro/panasonic_3do/roms"
  # "No-Intro/Philips - CD-i/:::no-intro/philips_cd-i/roms"
  # "No-Intro/Sega - 32X/:::no-intro/sega_32x/roms"
  # "No-Intro/Sega - Dreamcast/:::no-intro/sega_dreamcast/roms"
  # "No-Intro/Sega - Game Gear/:::no-intro/sega_game_gear/roms"
  # "No-Intro/Sega - Master System/:::no-intro/sega_master_system/roms"
  # "No-Intro/Sega - Mega Drive - Genesis/:::no-intro/sega_megadrive/roms"
  # "No-Intro/Sega - Saturn/:::no-intro/sega_saturn/roms"
  # "No-Intro/Sega - SG-1000/:::no-intro/sega_sg1000/roms"
  # "No-Intro/Sony - PlayStation/:::no-intro/sony_playstation/roms"
  # "No-Intro/Sony - PlayStation 2/:::no-intro/sony_playstation2/roms"
  # "No-Intro/Sony - PlayStation 3/:::no-intro/sony_playstation3/roms"
  # "No-Intro/Sony - PlayStation Portable/:::no-intro/sony_psp/roms"
  # "No-Intro/Sony - PlayStation Vita/:::no-intro/sony_psvita/roms"
  # "No-Intro/VTech - V.Smile/:::no-intro/vtech_vsmile/roms"

# -----------------------------
# 📦 UNOFFICIAL NO-INTRO COLLECTIONS
# -----------------------------

  # "No-Intro/Unofficial - Microsoft - Xbox 360 (Title Updates)/:::no-intro-unofficial/xbox360_title_updates"
  # "No-Intro/Unofficial - Nintendo - Nintendo 3DS (Digital) (Updates and DLC) (Decrypted)/:::no-intro-unofficial/3ds_digital_decrypted"
  # "No-Intro/Unofficial - Nintendo - Nintendo 3DS (Digital) (Updates and DLC) (Encrypted)/:::no-intro-unofficial/3ds_digital_encrypted"
  # "No-Intro/Unofficial - Nintendo - Wii (Digital) (Deprecated) (WAD)/:::no-intro-unofficial/wii_digital_deprecated"
  # "No-Intro/Unofficial - Nintendo - Wii (Digital) (Split DLC) (Deprecated) (WAD)/:::no-intro-unofficial/wii_digital_split_dlc"
  # "No-Intro/Unofficial - Nintendo - Wii U (Digital) (Deprecated)/:::no-intro-unofficial/wiiu_digital_deprecated"
  # "No-Intro/Unofficial - Sony - PlayStation 3 (PSN) (Decrypted)/:::no-intro-unofficial/ps3_psn_decrypted"
  # "No-Intro/Unofficial - Sony - PlayStation Portable (PSN) (Decrypted)/:::no-intro-unofficial/psp_psn_decrypted"
  # "No-Intro/Unofficial - Sony - PlayStation Portable (PSX2PSP)/:::no-intro-unofficial/psp_psx2psp"
  # "No-Intro/Unofficial - Sony - PlayStation Portable (UMD Music)/:::no-intro-unofficial/psp_umd_music"
  # "No-Intro/Unofficial - Sony - PlayStation Portable (UMD Video)/:::no-intro-unofficial/psp_umd_video"
  # "No-Intro/Unofficial - Sony - PlayStation Vita (BlackFinPSV)/:::no-intro-unofficial/psvita_blackfin"
  # "No-Intro/Unofficial - Sony - PlayStation Vita (NoNpDrm)/:::no-intro-unofficial/psvita_nonpdrm"
  # "No-Intro/Unofficial - Sony - PlayStation Vita (PSN) (Decrypted) (NoNpDrm)/:::no-intro-unofficial/psvita_psn_decrypted_nonpdrm"
  # "No-Intro/Unofficial - Sony - PlayStation Vita (PSN) (Decrypted) (VPK)/:::no-intro-unofficial/psvita_psn_decrypted_vpk"
  # "No-Intro/Unofficial - Sony - PlayStation Vita (PSVgameSD)/:::no-intro-unofficial/psvita_psvgamesd"
  # "No-Intro/Unofficial - Sony - PlayStation Vita (VPK)/:::no-intro-unofficial/psvita_vpk"
  # "No-Intro/Unofficial - Video Game Documents (PDF)/:::no-intro-unofficial/docs_pdf"
  # "No-Intro/Unofficial - Video Game Magazine Scans (CBZ)/:::no-intro-unofficial/magazines_cbz"
  # "No-Intro/Unofficial - Video Game Magazine Scans (PDF)/:::no-intro-unofficial/magazines_pdf"
  # "No-Intro/Unofficial - Video Game Magazine Scans (RAW)/:::no-intro-unofficial/magazines_raw"
  # "No-Intro/Unofficial - Video Game OSTs (Digital) (RAW)/:::no-intro-unofficial/osts_raw"
  # "No-Intro/Unofficial - Video Game Scans (RAW)/:::no-intro-unofficial/game_scans_raw"

# -----------------------------
# 📦 NO-INTRO SOURCE CODE COLLECTIONS
# -----------------------------

  # "No-Intro/Source Code - Mobile - Palm OS/:::No-Intro/Source_Code/Palm_OS"
  # "No-Intro/Source Code - Nintendo - Game Boy Advance/:::No-Intro/Source_Code/Game_Boy_Advance"
  # "No-Intro/Source Code - Nintendo - Nintendo - Game Boy Color/:::No-Intro/Source_Code/Game_Boy_Color"
  # "No-Intro/Source Code - Nintendo - Nintendo DS/:::No-Intro/Source_Code/Nintendo_DS"
  # "No-Intro/Source Code - Nintendo - Nintendo Entertainment System/:::No-Intro/Source_Code/NES"
  # "No-Intro/Source Code - Nintendo - Nintendo GameCube/:::No-Intro/Source_Code/GameCube"
  # "No-Intro/Source Code - Nintendo - Super Nintendo Entertainment System/:::No-Intro/Source_Code/SNES"
  # "No-Intro/Source Code - Panasonic - 3DO Interactive Multiplayer/:::No-Intro/Source_Code/3DO"
  # "No-Intro/Source Code - Sega - DreamCast/:::No-Intro/Source_Code/DreamCast"

# -----------------------------
# 📦 OFFICIAL REDUMP COLLECTIONS
# -----------------------------

  # "Redump/Arcade - Hasbro - VideoNow/:::Redump/Arcade/Hasbro_VideoNow"
  # "Redump/Arcade - Sega - Naomi/:::Redump/Arcade/Sega_Naomi"
  # "Redump/Arcade - Namco - Triforce/:::Redump/Arcade/Namco_Triforce"
  # "Redump/Bandai - Playdia Quick Interactive System/:::Redump/Playdia/roms"
  # "Redump/Commodore - Amiga CD/:::Redump/Amiga_CD/roms"
  # "Redump/Commodore - Amiga CD32/:::Redump/Amiga_CD32/roms"
  # "Redump/Commodore - Amiga CDTV/:::Redump/Amiga_CDTV/roms"
  # "Redump/DVD-Video/:::Redump/DVD_Video/roms"
  # "Redump/Fujitsu - FM-Towns/:::Redump/FM-Towns/roms"
  # "Redump/HD DVD-Video/:::Redump/HD_DVD_Video/roms"
  # "Redump/IBM - PC compatible/:::Redump/IBM_PC/roms"
  # "Redump/IBM - PC compatible - SBI Subchannels/:::Redump/IBM_PC_SBI/roms"
  # "Redump/Incredible Technologies - Eagle/:::Redump/Eagle/roms"
  # "Redump/Mattel - Fisher-Price iXL/:::Redump/iXL/roms"
  # "Redump/Mattel - HyperScan/:::Redump/HyperScan/roms"
  # "Redump/Memorex - Visual Information System/:::Redump/Visual_Information_System/roms"
  # "Redump/Microsoft - Xbox/:::Redump/Xbox/roms"
  # "Redump/Microsoft - Xbox - BIOS Images/:::Redump/Xbox/BIOS"
  # "Redump/Microsoft - Xbox 360/:::Redump/Xbox_360/roms"
  # "Redump/NEC - PC Engine CD & TurboGrafx CD/:::Redump/PC_Engine_CD/roms"
  # "Redump/NEC - PC-88 series/:::Redump/PC-88/roms"
  # "Redump/NEC - PC-98 series/:::Redump/PC-98/roms"
  # "Redump/NEC - PC-FX & PC-FXGA/:::Redump/PC-FX/roms"
  # "Redump/Navisoft - Naviken 2.1/:::Redump/Naviken_2.1/roms"
  # "Redump/Nintendo - GameCube - BIOS Images/:::Redump/GameCube/BIOS"
  # "Redump/Nintendo - GameCube - NKit RVZ [zstd-19-128k]/:::Redump/GameCube/NKit_RVZ/roms"
  # "Redump/Nintendo - Wii - NKit RVZ [zstd-19-128k]/:::Redump/Wii/NKit_RVZ/roms"
  # "Redump/Nintendo - Wii U - Disc Keys/:::Redump/Wii_U/Disc_Keys"
  # "Redump/Nintendo - Wii U - WUX/:::Redump/Wii_U/WUX/roms"
  # "Redump/Palm/:::Redump/Palm/roms"
  # "Redump/Panasonic - 3DO Interactive Multiplayer/:::Redump/3DO/roms"
  # "Redump/Panasonic - M2/:::Redump/M2/roms"
  # "Redump/Philips - CD-i/:::Redump/CD-i/roms"
  # "Redump/Photo CD/:::Redump/Photo_CD/roms"
  # "Redump/PlayStation GameShark Updates/:::Redump/PlayStation/GameShark_Updates"
  # "Redump/Pocket PC/:::Redump/Pocket_PC/roms"
  # "Redump/SNK - Neo Geo CD/:::Redump/Neo_Geo_CD/roms"
  # "Redump/Sega - Dreamcast/:::Redump/Dreamcast/roms"
  # "Redump/Sega - Dreamcast - GDI Files/:::Redump/Dreamcast/GDI_Files"
  # "Redump/Sega - Mega CD & Sega CD/:::Redump/Sega_CD/roms"
  # "Redump/Sega - Prologue 21/:::Redump/Prologue_21/roms"
  # "Redump/Sega - Saturn/:::Redump/Saturn/roms"
  # "Redump/Sharp - X68000/:::Redump/X68000/roms"
  # "Redump/Sony - PlayStation/:::Redump/PlayStation/roms"
  # "Redump/Sony - PlayStation - BIOS Images/:::Redump/PlayStation/BIOS"
  # "Redump/Sony - PlayStation - SBI Subchannels/:::Redump/PlayStation/SBI_Subchannels"
  # "Redump/Sony - PlayStation 2/:::Redump/PlayStation_2/roms"
  # "Redump/Sony - PlayStation 2 - BIOS Images/:::Redump/PlayStation_2/BIOS"
  # "Redump/Sony - PlayStation 3/:::Redump/PlayStation_3/roms"
  # "Redump/Sony - PlayStation 3 - Disc Keys/:::Redump/PlayStation_3/Disc_Keys"
  # "Redump/Sony - PlayStation 3 - Disc Keys TXT/:::Redump/PlayStation_3/Disc_Keys_TXT"
  # "Redump/Sony - PlayStation Portable/:::Redump/PSP/roms"
  # "Redump/TAB-Austria - Quizard/:::Redump/Quizard/roms"
  # "Redump/Tomy - Kiss-Site/:::Redump/Kiss-Site/roms"
  # "Redump/VM Labs - NUON/:::Redump/NUON/roms"
  # "Redump/VTech - V.Flash & V.Smile Pro/:::Redump/VTech/roms"
  # "Redump/Video CD/:::Redump/Video_CD/roms"
  # "Redump/ZAPiT Games - Game Wave Family Entertainment System/:::Redump/Game_Wave/roms"
  # "Redump/funworld - Photo Play/:::Redump/Photo_Play/roms"

# -----------------------------
# 📦 MISC REDUMP COLLECTIONS
# -----------------------------

  # "Redump/Random - Covers and Scans/:::Redump/Misc/Covers_Scans"
  # "Redump/Random - Disc Tools/:::Redump/Misc/Disc_Tools"
  # "Redump/Random - Logs/:::Redump/Misc/Logs"
  # "Redump/Random - Applications/:::Redump/Misc/Apps"

)

# 💿 SYSTEM BIOS TO SYNC
# Format: "myrient_folder_path:::local_folder"
# ➤ Copy/paste entries from below to include in BIOS_PATHS

# ┌─────────────────────────────────────────────────────────────────────┐
# │                    💿 SYSTEM BIOS TO SYNC                          │
# └─────────────────────────────────────────────────────────────────────┘
# ➤ BIOS files are essential for emulation on many systems.
# ➤ Format: "myrient_folder_path:::local_folder"
#     - Left side: remote path on myrient
#     - Right side: relative destination on your system
#
# 💡 Tip: Enable the BIOS entries for any systems you've activated above.
# 💡 These are pulled from Redump’s "BIOS Images" collections.

BIOS_PATHS=(
  "Redump/Nintendo - GameCube - BIOS Images:::Redump/gamecube/bios"
  # "Redump/Sony - PlayStation - BIOS Images:::Redump/psx/bios"
  # "Redump/Sony - PlayStation 2 - BIOS Images:::Redump/ps2/bios"
  # "Redump/Microsoft - Xbox - BIOS Images:::Redump/xbox/bios"
  # "Redump/Sony - PlayStation 3 - BIOS Images:::Redump/ps3/bios"

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
  "Redump/Nintendo - Wii U - Disc Keys:::Redump/wiiu/disk_keys"
  # "Redump/Sony - PlayStation 3 - Disc Keys:::Redump/ps3/disk_keys"
  # "Redump/Sony - PlayStation 3 - Disc Keys TXT:::Redump/ps3/disk_keys_txt"
)

################################################################################
# SCRIPT STARTS BELOW - DO NOT EDIT UNLESS YOU KNOW WHAT YOU'RE DOING
################################################################################

GREEN="\e[32m"  # ANSI color code for green text (used for success messages)
RED="\e[31m"    # ANSI color code for red text (used for errors)
RESET="\e[0m"   # Resets terminal color formatting back to default

LOG_FILE="$GAMES_LOCAL_PATH/sync-$(date +%F_%H-%M-%S).log"  # Log file with timestamp to avoid overwrites
VERIFIED_LOG="$GAMES_LOCAL_PATH/.verified_files.log"        # Hidden log file to track already-verified files
touch "$VERIFIED_LOG"  # Ensures the verified log file exists
SECONDS=0              # Start timer for script duration (used with $TIMER toggle)


# Base rclone flags used for all sync operations
RCLONE_FLAGS="--ignore-case --progress --http-no-head --create-empty-src-dirs \
--transfers=$TRANSFERS --checkers=$CHECKERS --retries=$RETRIES --multi-thread-streams=$STREAMS \
--multi-thread-cutoff=$CUTOFF --low-level-retries=$LOW_LEVEL_RETRIES --retries-sleep=10s --skip-links \
--use-server-modtime --copy-links"


# Add toggle-based rclone options dynamically
[ "$DRY_RUN" = true ] && RCLONE_FLAGS+=" --dry-run"                # Do not actually download files
[ "$ONLY_NEW" = true ] && RCLONE_FLAGS+=" --ignore-existing"       # Skip files that already exist locally
[ "$FORCE_OVERWRITES" = true ] && RCLONE_FLAGS+=" --ignore-times"  # Force overwriting regardless of timestamp
[ "$RCLONE_CHECK" = true ] && RCLONE_FLAGS+=" --recheck"           # Recheck all files regardless of existing match
[ "$VERIFY_POST_SYNC" = true ] && RCLONE_FLAGS+=" --size-only"     # Use size comparison for rclone copy (initial sync)


echo -e "\n📄 Logging to: $LOG_FILE\n"
find "$GAMES_LOCAL_PATH" -name "sync-*.log" -mtime +$RETENTION_DAYS -delete  # Prune old logs beyond retention window

# -----------------------------
# RCLONE INSTALL CHECK
# This section ensures that rclone is installed.
# If it's not found and the system is Linux, it attempts to auto-install it.
# You can safely remove this block if you prefer manual rclone installation.
# -----------------------------
if ! command -v rclone &> /dev/null; then
  echo -e "${RED}⚠ rclone is not installed.${RESET}"

  # Check if we're on a Linux system (only supported for auto-install)
  if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo -e "${RED}⚠ This script only auto-installs rclone on Linux. Please install it manually:${RESET}"
    echo "➡ https://rclone.org/downloads/"
    exit 1
  fi

  # Ensure curl is available for downloading the install script
  if ! command -v curl &> /dev/null; then
    echo -e "${RED}❌ curl is required to install rclone. Please install curl or rclone manually.${RESET}"
    exit 1
  fi

  # Require root privileges for installation
  if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run this script as root to auto-install rclone.${RESET}"
    exit 1
  fi

  # Prompt the user for confirmation before proceeding
  read -p "rclone is not installed. Install it now? (y/N): " -r
  [[ $REPLY =~ ^[Yy]$ ]] || exit 1

  # Attempt to download and run the official rclone install script
  if curl -s https://rclone.org/install.sh | sudo bash; then
    echo -e "${GREEN}✅ rclone installed successfully.${RESET}"
  else
    echo -e "${RED}❌ Failed to install rclone. Install it manually from https://rclone.org/downloads/${RESET}"
    exit 1
  fi
fi
# END OF BLOCK

# -----------------------------
# REMOTE CONFIG CHECK
# This section checks whether an rclone remote named "$REMOTE_NAME" already exists.
# If it doesn't, the script auto-creates it using the HTTP backend.
# This remote points to https://myrient.erista.me/files/ — the base URL for Myrient content.
# You can safely remove this block if you prefer to create/configure the remote manually.
# -----------------------------

# Check if the remote exists in the current rclone config
if ! rclone listremotes | grep -q "^$REMOTE_NAME:"; then
  echo -e "${RED}⚠ Remote '$REMOTE_NAME' not found.${RESET}"
  echo -e "🔧 Attempting to create it..."

  # Create the remote using rclone's HTTP backend
  rclone config create "$REMOTE_NAME" http \
    url "https://myrient.erista.me/files/" \   # Set base URL for Myrient
    vendor "other" \                           # Generic vendor type
    2>/dev/null                                # Suppress error output

  # Confirm the remote was created successfully
  if rclone listremotes | grep -q "^$REMOTE_NAME:"; then
    echo -e "${GREEN}✅ Remote '$REMOTE_NAME' created successfully.${RESET}"
  else
    echo -e "${RED}❌ Failed to create remote '$REMOTE_NAME'. Please create it manually with:${RESET}"
    echo -e "${RED}   rclone config${RESET}"
    exit 1
  fi
fi
# END OF BLOCK

# Set up a signal trap for Ctrl+C (SIGINT) or termination (SIGTERM)
# If interrupted, it prints a message, kills any background jobs, and exits cleanly.
trap "echo -e '\n${RED}⛔ Interrupted. Exiting...${RESET}'; kill 0; exit 1" SIGINT SIGTERM

# Ensure the base local destination directory exists (creates it if missing)
mkdir -p "$GAMES_LOCAL_PATH"

# Check how much disk space is available on the target filesystem
# Uses 'df -h' and grabs the 4th column of the 2nd line (the available space)
AVAILABLE_SPACE=$(df -h "$GAMES_LOCAL_PATH" | awk 'NR==2 {print $4}')

# Display available space to the user
echo -e "📥 Available disk space: $AVAILABLE_SPACE"

# -----------------------------
# FILTERS
# This section builds a dynamic rclone filter list to:
#  - Exclude unwanted patterns (e.g., sports games)
#  - Include specific desired patterns (e.g., USA/NTSC/World ROMs)
#  - Block everything else not explicitly included
# -----------------------------

FILTERS=()  # Initialize empty filter array

# Append exclusion rules
for pattern in "${EXCLUDES[@]}"; do
  FILTERS+=(--filter="- $pattern")
done

# Append inclusion rules
for pattern in "${INCLUDES[@]}"; do
  FILTERS+=(--filter="+ $pattern")
done

# Catch-all: exclude anything not explicitly included
FILTERS+=(--filter="- *")

# END OF BLOCK

# -----------------------------
# BIOS & DISC KEYS
# This section syncs all BIOS and disc key files defined in BIOS_PATHS and DISC_KEYS_PATHS.
# These are essential for emulator compatibility and decrypting certain games.
# -----------------------------

echo -e "\n🔑 Syncing BIOS and Disc Keys..."

# Combine BIOS and Disc Key paths into one list
EXTRAS=("${BIOS_PATHS[@]}" "${DISC_KEYS_PATHS[@]}")

# Counters for tracking success and failure
EXTRA_SUCCESS_COUNT=0
EXTRA_FAIL_COUNT=0
FAILED_EXTRAS=()

# Loop through all extra paths (BIOS + disc keys)
for entry in "${EXTRAS[@]}"; do
  SRC="$REMOTE_NAME:${entry%%:::*}"                        # Extract remote path before ::: 
  DEST="$GAMES_LOCAL_PATH/${entry##*:::}"                 # Extract local path after ::: 
  mkdir -p "$DEST"                                        # Ensure destination folder exists

  {
    echo -e "\n------------------------------------------"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 🔑 Syncing Extra: $SRC"
    echo "⬇ To: $DEST"
    echo "------------------------------------------"

    # Perform the rclone sync with previously defined flags
    if ! rclone copy $RCLONE_FLAGS "$SRC" "$DEST" 2>&1 | tee -a "$LOG_FILE"; then
      echo -e "${RED}❌ Failed: $SRC${RESET}" | tee -a "$LOG_FILE"
      ((EXTRA_FAIL_COUNT++))
      FAILED_EXTRAS+=("$SRC")                            # Track failed paths
    else
      ((EXTRA_SUCCESS_COUNT++))
    fi
  }
done

# -----------------------------
# POST-SYNC VERIFICATION (if enabled)
# -----------------------------
if [ "$VERIFY_POST_SYNC" = true ]; then
  echo -e "\n🔁 Auto-retrying failed BIOS/Key verifications..."
  [ "$USE_CHECKSUM" = true ] && echo -e "🔒 Using checksum verification" || echo -e "⚡ Using size-only verification"

  # Loop through the same BIOS/disc key entries for verification
  for entry in "${EXTRAS[@]}"; do
    SRC_PATH="${entry%%:::*}"                            # Remote subpath
    SRC="$REMOTE_NAME:$SRC_PATH"
    DEST="$GAMES_LOCAL_PATH/${entry##*:::}"             # Local path
    CHECK_LOG=$(mktemp)                                 # Temp file for rclone check output

    # Choose verification method (size or checksum)
    CHECK_FLAG="--size-only"
    [ "$USE_CHECKSUM" = true ] && CHECK_FLAG="--checksum"

    echo -e "🔍 Verifying $SRC vs $DEST using $CHECK_FLAG"
    rclone check "$SRC" "$DEST" $CHECK_FLAG 2>&1 | tee -a "$LOG_FILE" | tee "$CHECK_LOG"

    # Parse rclone check log for failed files and retry them individually
    grep -E 'ERROR.*(not found at destination|sizes differ|hash differ)' "$CHECK_LOG" | awk -F: '{print $2}' | sed 's/^[[:space:]]*//' | while read -r FILE; do
      FILE_REL="${FILE#${SRC_PATH}/}"                  # Get file path relative to the remote root
      FILE_FULL="$SRC/$FILE_REL"                       # Full remote file path

      # Skip retry if the file has already been verified
      if [ "$SKIP_VERIFIED_FILES" = true ] && grep -Fxq "$FILE_FULL" "$VERIFIED_LOG"; then
        echo "✅ Skipping already verified: $FILE_REL"
        continue
      fi

      echo "🔁 Retrying: $FILE_REL"

      # Retry the file up to MAX_RETRY_COUNT times
      for ((i=1; i<=MAX_RETRY_COUNT; i++)); do
        echo "  🔄 Attempt $i/$MAX_RETRY_COUNT..."
        rclone copy "$FILE_FULL" "$DEST/$(dirname "$FILE_REL")" --create-empty-src-dirs $RCLONE_FLAGS >> "$LOG_FILE" 2>&1

        echo "  🔍 Rechecking..."
        if rclone check "$FILE_FULL" "$DEST/$FILE_REL" $CHECK_FLAG >> "$LOG_FILE" 2>&1; then
          echo "✅ Verified after retry: $FILE_REL"
          echo "$FILE_FULL" >> "$VERIFIED_LOG"        # Mark as verified
          break
        fi

        # Final failure message if all retries exhausted
        if (( i == MAX_RETRY_COUNT )); then
          echo -e "${RED}❌ Retry failed for $FILE_REL after $MAX_RETRY_COUNT attempts.${RESET}" | tee -a "$LOG_FILE"
        fi
      done
    done

    rm -f "$CHECK_LOG"  # Clean up temp log file
  done
fi
# END OF BIOS & DISC KEYS BLOCK


# -----------------------------
# SYSTEMS SYNC
# This section handles syncing all selected ROM systems listed in the SYSTEMS array.
# It also applies include/exclude filters and optionally verifies and retries failed transfers.
# -----------------------------

echo -e "\n🎮 Syncing ROM Systems..."

# Initialize counters for tracking success/failure
SYSTEM_SUCCESS_COUNT=0
SYSTEM_FAIL_COUNT=0
FAILED_SYSTEMS=()

# Loop through each system entry defined in the SYSTEMS array
for system in "${SYSTEMS[@]}"; do
  SRC="$REMOTE_NAME:${system%%:::*}"                      # Remote source path before ::: (myrient path)
  DEST="$GAMES_LOCAL_PATH/${system##*:::}"                # Local destination path after ::: (relative path)
  mkdir -p "$DEST"                                        # Create local destination directory

  {
    echo -e "\n=========================================="
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ▶ Syncing: $SRC"
    echo "⬇ To: $DEST"
    echo "=========================================="

    # Attempt to copy files using rclone with configured flags and filters
    if ! rclone copy $RCLONE_FLAGS "${FILTERS[@]}" "$SRC" "$DEST" 2>&1 | tee -a "$LOG_FILE"; then
      echo -e "${RED}❌ Failed: $SRC${RESET}" | tee -a "$LOG_FILE"
      ((SYSTEM_FAIL_COUNT++))                              # Increment failure counter
      FAILED_SYSTEMS+=("$SRC")                             # Track failed systems
    else
      ((SYSTEM_SUCCESS_COUNT++))                           # Increment success counter
    fi
  }
done

# -----------------------------
# POST-SYNC VERIFICATION (if enabled)
# -----------------------------
if [ "$VERIFY_POST_SYNC" = true ]; then
  echo -e "\n🔁 Auto-retrying failed ROM system verifications..."
  [ "$USE_CHECKSUM" = true ] && echo -e "🔒 Using checksum verification" || echo -e "⚡ Using size-only verification"

  # Loop through each system again for verification
  for system in "${SYSTEMS[@]}"; do
    SRC_PATH="${system%%:::*}"                             # Remote subpath
    SRC="$REMOTE_NAME:$SRC_PATH"
    DEST="$GAMES_LOCAL_PATH/${system##*:::}"              # Local path
    CHECK_LOG=$(mktemp)                                   # Temp file to hold check results

    # Select verification method
    CHECK_FLAG="--size-only"
    [ "$USE_CHECKSUM" = true ] && CHECK_FLAG="--checksum"

    echo -e "🔍 Verifying $SRC vs $DEST using $CHECK_FLAG"
    rclone check "$SRC" "$DEST" $CHECK_FLAG "${FILTERS[@]}" 2>&1 | tee -a "$LOG_FILE" | tee "$CHECK_LOG"

    # Retry files that failed verification
    grep -E 'ERROR.*(not found at destination|sizes differ|hash differ)' "$CHECK_LOG" | awk -F: '{print $2}' | sed 's/^[[:space:]]*//' | while read -r FILE; do
      FILE_REL="${FILE#${SRC_PATH}/}"                     # Relative file path under the remote
      FILE_FULL="$SRC/$FILE_REL"                          # Full path for rclone access

      # Skip retry if already verified
      if [ "$SKIP_VERIFIED_FILES" = true ] && grep -Fxq "$FILE_FULL" "$VERIFIED_LOG"; then
        echo "✅ Skipping already verified: $FILE_REL"
        continue
      fi

      echo "🔁 Retrying: $FILE_REL"

      # Retry file up to MAX_RETRY_COUNT times
      for ((i=1; i<=MAX_RETRY_COUNT; i++)); do
        echo "  🔄 Attempt $i/$MAX_RETRY_COUNT..."
        rclone copy "$FILE_FULL" "$DEST/$(dirname "$FILE_REL")" --create-empty-src-dirs $RCLONE_FLAGS >> "$LOG_FILE" 2>&1

        echo "  🔍 Rechecking..."
        if rclone check "$FILE_FULL" "$DEST/$FILE_REL" $CHECK_FLAG >> "$LOG_FILE" 2>&1; then
          echo "✅ Verified after retry: $FILE_REL"
          echo "$FILE_FULL" >> "$VERIFIED_LOG"            # Save to verified log
          break
        fi

        # Log final failure after exhausting all retries
        if (( i == MAX_RETRY_COUNT )); then
          echo -e "${RED}❌ Retry failed for $FILE_REL after $MAX_RETRY_COUNT attempts.${RESET}" | tee -a "$LOG_FILE"
        fi
      done
    done

    rm -f "$CHECK_LOG"  # Clean up temporary check log
  done
fi
# END OF SYSTEMS SYNC BLOCK


# -----------------------------
# RETRY SCRIPTS
# This section generates standalone retry scripts for any failed BIOS/disc key or system syncs.
# These scripts can be run later to attempt to re-download only the failed paths.
# -----------------------------

# If retry scripts are enabled AND there were failed BIOS/Disc Key entries...
if [ "$CREATE_RETRY_SCRIPTS" = true ] && [ ${#FAILED_EXTRAS[@]} -gt 0 ]; then

  # Define the retry script file path with a timestamp
  RETRY_FILE="$GAMES_LOCAL_PATH/retry_failed_extras_$(date +%F_%H-%M-%S).sh"
  echo "#!/bin/bash" > "$RETRY_FILE"       # Start the script with a shebang
  chmod +x "$RETRY_FILE"                   # Make the script executable

  # Write rclone commands for each failed BIOS/Disc Key path
  for path in "${FAILED_EXTRAS[@]}"; do
    local_path="${path#${REMOTE_NAME}:}"   # Strip the remote name prefix from the path
    echo "rclone copy $RCLONE_FLAGS \"$path\" \"$GAMES_LOCAL_PATH/$local_path\"" >> "$RETRY_FILE"
  done

  echo -e "🔁 Retry script saved to: $RETRY_FILE" | tee -a "$LOG_FILE"
fi

# If retry scripts are enabled AND there were failed ROM system entries...
if [ "$CREATE_RETRY_SCRIPTS" = true ] && [ ${#FAILED_SYSTEMS[@]} -gt 0 ]; then

  # Define the retry script file path with a timestamp
  RETRY_FILE="$GAMES_LOCAL_PATH/retry_failed_systems_$(date +%F_%H-%M-%S).sh"
  echo "#!/bin/bash" > "$RETRY_FILE"       # Start the script with a shebang
  chmod +x "$RETRY_FILE"                   # Make the script executable

  # Write rclone commands for each failed system path with filters applied
  for path in "${FAILED_SYSTEMS[@]}"; do
    local_path="${path#${REMOTE_NAME}:}"   # Strip the remote name prefix from the path
    echo "rclone copy $RCLONE_FLAGS ${FILTERS[*]} \"$path\" \"$GAMES_LOCAL_PATH/$local_path\"" >> "$RETRY_FILE"
  done

  echo -e "🔁 Retry script saved to: $RETRY_FILE" | tee -a "$LOG_FILE"
fi
# END OF BLOCK

# -----------------------------
# FINAL SUMMARY
# This section prints a summary of the sync operation results.
# It includes success/failure counts, retry script status, log cleanup, and optional timing.
# -----------------------------

# Print summary header
echo -e "\n📋 ${GREEN}Summary:${RESET}" | tee -a "$LOG_FILE"

# Show BIOS/Disc Key sync results
echo -e "🔑 BIOS/Keys: $EXTRA_SUCCESS_COUNT success, $EXTRA_FAIL_COUNT failed" | tee -a "$LOG_FILE"

# Show ROM system sync results
echo -e "🎮 Systems : $SYSTEM_SUCCESS_COUNT success, $SYSTEM_FAIL_COUNT failed" | tee -a "$LOG_FILE"

# Indicate if retry script generation was disabled
[ "$CREATE_RETRY_SCRIPTS" = false ] && echo -e "🔁 Retry script generation is disabled." | tee -a "$LOG_FILE"

# Confirm that old logs were purged based on the RETENTION_DAYS setting
echo -e "🗑️  Logs older than $RETENTION_DAYS days cleaned up" | tee -a "$LOG_FILE"

# Show a warning if DRY_RUN is enabled, reminding user no files were actually copied
[ "$DRY_RUN" = true ] && echo -e "${RED}⚠ DRY_RUN is enabled. No files were copied.\n🔜 Set DRY_RUN=false when you're ready to sync for real.${RESET}" | tee -a "$LOG_FILE"

# Print how long the script ran (if TIMER is enabled)
[ "$TIMER" = true ] && echo -e "⏱️ Duration: $((SECONDS / 60))m $((SECONDS % 60))s" | tee -a "$LOG_FILE"

# Final success message
echo -e "\n🏎️ ${GREEN}All sync operations complete.${RESET}" | tee -a "$LOG_FILE"
# END OF BLOCK

# END
