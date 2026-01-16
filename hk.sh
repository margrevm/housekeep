#!/bin/bash

## Script to clean up disk space (unnecessary or old files, cache, ...)
##
## Copyright (C) 2026 Mike Margreve (mike.margreve@outlook.com)
## Permission to copy and modify is granted under the MIT license
##
## Usage: hk [no arguments]

prompt_continue() {
  local prompt="${1:-Proceed with burn?}"
  printf "%s [y/N]: " "$prompt"
  read -r ans
  case "${ans:-}" in
    y|Y|yes|YES) return 0 ;;
    *) echo "Abort acknowledged. Holding position."; exit 1 ;;
  esac
}

log_section() {
  printf "\n\033[1;34m[%s]\033[0m\n" "$1"
  prompt_continue "Continue burn"
}

log_step() {
  printf "\033[0;34m➜ %s\033[0m\n" "$1"
}

log_warn() {
  printf "WARN: %s\n" "$1"
  prompt_continue "Continue burn anyway"
}

# ---------------------------------------------------
# Remove old files
# ---------------------------------------------------

CLEANUP_DIRS=(
    "$HOME/Downloads"
    "$HOME/Pictures/Screenshots"
    "$HOME/Screencasts"
)

NB_DAYS_TO_KEEP=60

# Remove files older than NB_DAYS_TO_KEEP days in the specified folders
log_section "Removing old files & folders"
for CLEANUP_DIR in "${CLEANUP_DIRS[@]}"; do
    if [ -d "$CLEANUP_DIR" ]; then

        log_step "Files older than ${NB_DAYS_TO_KEEP} days in '$CLEANUP_DIR'"
        mapfile -d '' -t FILES_TO_DELETE < <(find "$CLEANUP_DIR" -type f -mtime +"$NB_DAYS_TO_KEEP" -print0)
        if [ "${#FILES_TO_DELETE[@]}" -eq 0 ]; then
            echo "No files to delete."
            continue
        fi

        # Print file list with sizes
        for FILE in "${FILES_TO_DELETE[@]}"; do
            FILE_SIZE=$(du -h --apparent-size -- "$FILE" | awk '{print $1}')
            printf "%s %s\n" "$FILE" "$FILE_SIZE"
        done
        
        # Calculate total size and ask for confirmation
        TOTAL_SIZE=$(
            printf '%s\0' "${FILES_TO_DELETE[@]}" \
              | du -ch --files0-from=- 2>/dev/null \
              | awk '/total$/ {print $1}'
        )

        # Ensure TOTAL_SIZE is a single line
        TOTAL_SIZE=$(echo "$TOTAL_SIZE" | tr -d '\n')
        printf '\n'
        read -p "Jettison these files (Total size: $TOTAL_SIZE)? [y/N]: " CONFIRM

        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            echo "Jettisoning files..."
            # Delete the files
            printf '%s\0' "${FILES_TO_DELETE[@]}" | xargs -0 rm -v --
        else
            echo "Skipped jettisoning files in '$CLEANUP_DIR'."
        fi
    else
        log_step "Directory '$CLEANUP_DIR' does not exist. Skipping..."
    fi
done

# ---------------------------------------------------
# Remove empty folders (recursively in the given folders)
# ---------------------------------------------------
REMOVE_EMPTY_DIRS=(
    "$HOME/Downloads"
    "$HOME/Pictures/Screenshots"
)

log_section "Removing empty folders"
for REMOVE_EMPTY_DIR in "${REMOVE_EMPTY_DIRS[@]}"; do
    if [ -d "$REMOVE_EMPTY_DIR" ]; then
        if [ -z "$(find "$REMOVE_EMPTY_DIR" -depth -type d -empty)" ]; then
            # print message that nothing has been found if no empty folders were found
            log_step "No empty folders found in '$REMOVE_EMPTY_DIR'"
        fi  

        find "$REMOVE_EMPTY_DIR" -depth -type d -empty -exec rmdir -v {} \;
    fi
done

# ---------------------------------------------------
# Remove dirs alltogether
# ---------------------------------------------------
REMOVE_DIRS=(
    "$HOME/Screencasts"
    "$HOME/cpdb"
)

log_section "Removing unused folders"
rm -rfv -- "${REMOVE_DIRS[@]}"

# ---------------------------------------------------
# Clean trash
# ---------------------------------------------------
log_section "Clean trash"
# Trash is cleaned by setting a period in Settings->Privacy->File History & Trash
