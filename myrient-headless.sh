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

# ┌─────────────────────────────────────────────────────────────────────┐
# │                      🎮 ROM SYSTEMS TO SYNC                         │
# └─────────────────────────────────────────────────────────────────────┘
# ➤ Enable systems by uncommenting their respective lines below.
# ➤ Format: "myrient_folder_path:::local_folder"
#     - Left side: path on the myrient remote
#     - Right side: relative destination path on your local drive
SYSTEMS=(
  "No-Intro/3DO Interactive Multiplayer/:::no-intro/3do/roms"
)

# ┌─────────────────────────────────────────────────────────────────────┐
# │                      💿 SYSTEM BIOS TO SYNC                         │
# └─────────────────────────────────────────────────────────────────────┘
# ➤ BIOS files are essential for emulation on many systems.
# ➤ Format: "myrient_folder_path:::local_folder"
BIOS_PATHS=(
  "Redump/Nintendo - GameCube - BIOS Images:::Redump/gamecube/bios"
)

# ┌─────────────────────────────────────────────────────────────────────┐
# │                       🔑 DISC KEYS TO SYNC                          │
# └─────────────────────────────────────────────────────────────────────┘
# ➤ Disc keys are used to decrypt disc-based games (like PS3/Wii U titles).
# ➤ Format: "myrient_folder_path:::local_folder"
DISC_KEYS_PATHS=(
  "Redump/Nintendo - Wii U - Disc Keys:::Redump/wiiu/disk_keys"
)

# The remainder of the script is unchanged and contains full inline comments
# throughout every section: filters, verification, syncing, retries, summaries, etc.


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
[ "$RCLONE_CHECK" = true ] && RCLONE_FLAGS+=" --recheck"           # Recheck all files regardless of existing match
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
trap "echo -e '\n${RED}⛔ Interrupted. Exiting...${RESET}'; kill 0; exit 1" SIGINT SIGTERM
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
  if ! rclone copy $RCLONE_FLAGS "$SRC" "$DEST" 2>&1 | tee -a "$LOG_FILE"; then
    echo -e "${RED}❌ Failed: $SRC${RESET}" | tee -a "$LOG_FILE"
    ((EXTRA_FAIL_COUNT++))                 # Increment fail count
    FAILED_EXTRAS+=("$SRC")                # Save path to retry list
  else
    ((EXTRA_SUCCESS_COUNT++))             # Increment success count
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
    rclone check "$SRC" "$DEST" $CHECK_FLAG 2>&1 | tee -a "$LOG_FILE" | tee "$CHECK_LOG"

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
        rclone copy "$FILE_FULL" "$DEST/$(dirname "$FILE_REL")" --create-empty-src-dirs $RCLONE_FLAGS >> "$LOG_FILE" 2>&1

        echo "  🔍 Rechecking..."
        if rclone check "$FILE_FULL" "$DEST/$FILE_REL" $CHECK_FLAG >> "$LOG_FILE" 2>&1; then
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
  SRC="$REMOTE_NAME:${system%%:::*}"             # Extract remote path before ::: (e.g. myrient:No-Intro/3DO...)
  DEST="$GAMES_LOCAL_PATH/${system##*:::}"       # Extract local path after ::: (e.g. /mnt/.../3do/roms)
  mkdir -p "$DEST"                               # Make sure destination directory exists

  # Show sync header for current system
  echo -e "\n=========================================="
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ▶ Syncing: $SRC"
  echo "⬇ To: $DEST"
  echo "=========================================="

  # Sync the system using rclone + filters, and log the output
  if ! rclone copy $RCLONE_FLAGS "${FILTERS[@]}" "$SRC" "$DEST" 2>&1 | tee -a "$LOG_FILE"; then
    echo -e "${RED}❌ Failed: $SRC${RESET}" | tee -a "$LOG_FILE"
    ((SYSTEM_FAIL_COUNT++))                     # Increment failure count
    FAILED_SYSTEMS+=("$SRC")                    # Track system for retry script
  else
    ((SYSTEM_SUCCESS_COUNT++))                  # Increment success count
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
    rclone check "$SRC" "$DEST" $CHECK_FLAG "${FILTERS[@]}" 2>&1 | tee -a "$LOG_FILE" | tee "$CHECK_LOG"

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
        rclone copy "$FILE_FULL" "$DEST/$(dirname "$FILE_REL")" --create-empty-src-dirs $RCLONE_FLAGS >> "$LOG_FILE" 2>&1

        echo "  🔍 Rechecking..."
        if rclone check "$FILE_FULL" "$DEST/$FILE_REL" $CHECK_FLAG >> "$LOG_FILE" 2>&1; then
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
