#!/bin/bash

VERSION=0.5
readable_name='[TouchID for sudo]'
executable_name='sudo-touchid'

# PAM configuration
PAM_TOUCHID='auth       sufficient     pam_tid.so'
PAM_REATTACH_PATH='/opt/homebrew/lib/pam/pam_reattach.so'
PAM_REATTACH='auth       optional       /opt/homebrew/lib/pam/pam_reattach.so'

# File paths  
SUDO_PATH='/etc/pam.d/sudo'
SUDO_LOCAL_PATH='/etc/pam.d/sudo_local'
LEGACY_PAM_FILE='/etc/pam.d/sudo_touchid'

usage() {
  cat <<EOF

  Usage: $executable_name [options]
    Running without options adds TouchID parameter to sudo configuration, or migrates an existing legacy configuration if you have upgraded from macOS 13 or below.

  Options:
    -d,  --disable     Remove TouchID from sudo config
    --with-reattach    Include pam_reattach.so for GUI session reattachment
    --migrate          Migrate from legacy configuration to new system

    -v,  --version     Output version
    -h,  --help        This message.

EOF
}

# Source: https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
getc() {
  local save_state
  save_state="$(/bin/stty -g)"
  /bin/stty raw -echo
  IFS='' read -r -n 1 -d '' "$@"
  /bin/stty "${save_state}"
}
wait_for_user() {
  local c
  echo
  echo "Press RETURN to continue or any other key to abort"
  getc c
  # we test for \r and \n because some stuff does \r instead
  if ! [[ "${c}" == $'\r' || "${c}" == $'\n' ]]; then
    exit 1
  fi
}
# Source end.

# Utility functions

detect_os_version() {
  sw_vers -productVersion | cut -d. -f1
}


create_pam_content() {
  local include_reattach="$1"
  
  echo "# TouchID for sudo - created by sudo-touchid v$VERSION"
  
  if [[ "$include_reattach" == "true" ]]; then
    echo "$PAM_REATTACH"
  fi
  
  echo "$PAM_TOUCHID"
}


install_file() {
  local content="$1"
  local target_path="$2"
  local permissions="$3"
  
  local temp_file
  temp_file=$(mktemp 2>/dev/null)
  
  if [[ -z "$temp_file" ]]; then
    echo "Error: Unable to create temporary file. Check /tmp directory permissions and available space."
    echo "Please ensure /tmp exists, is writable, and has sufficient space."
    return 1
  fi
  
  if ! echo "$content" > "$temp_file" 2>/dev/null; then
    echo "Error: Unable to write to temporary file. Check /tmp directory permissions and available space."
    echo "Please ensure /tmp exists, is writable, and has sufficient space."
    rm -f "$temp_file" 2>/dev/null
    return 1
  fi
  
  if sudo install -m "$permissions" "$temp_file" "$target_path"; then
    rm -f "$temp_file"
    return 0
  else
    rm -f "$temp_file"
    return 1
  fi
}

check_legacy_configuration() {
  [[ -f "$LEGACY_PAM_FILE" ]] || grep -q "pam_tid.so" "$SUDO_PATH" 2>/dev/null
}

migrate_legacy_configuration() {
  echo "Migrating from legacy TouchID configuration..."
  
  local major_version
  major_version=$(detect_os_version)
  
  # Remove legacy PAM file if it exists
  if [[ -f "$LEGACY_PAM_FILE" ]]; then
    sudo rm -f "$LEGACY_PAM_FILE"
    echo "Removed legacy PAM file: $LEGACY_PAM_FILE"
  fi
  
  
  # Remove TouchID and pam_reattach from /etc/pam.d/sudo if present
  if grep -q "pam_tid.so\|pam_reattach.so" "$SUDO_PATH" 2>/dev/null; then
    sudo cp "$SUDO_PATH" "$SUDO_PATH.bak"
    sudo sed -i '.bak' '/pam_tid\.so/d' "$SUDO_PATH"
    sudo sed -i '.bak' '/pam_reattach\.so/d' "$SUDO_PATH"
    echo "Removed TouchID configuration from $SUDO_PATH (backup saved as $SUDO_PATH.bak)"
  fi
  
  echo "Legacy configuration removed successfully."
}

sudo_touchid_pamlocal_install() {
  local include_reattach="$1"
  
  echo "Installing TouchID configuration for macOS 14+"
  
  # Create PAM configuration for sudo_local
  local pam_content
  pam_content=$(create_pam_content "$include_reattach")
  
  if ! install_file "$pam_content" "$SUDO_LOCAL_PATH" "644"; then
    echo "Error: Failed to create $SUDO_LOCAL_PATH"
    return 1
  fi
  
  echo "Created $SUDO_LOCAL_PATH"
  echo
  echo "$readable_name enabled successfully for macOS 14+."
  echo "Note: If TouchID for sudo stops working, you can disable it with: sudo-touchid --disable"
  
  return 0
}

sudo_touchid_legacy_install() {
  local include_reattach="$1"
  
  echo "Installing TouchID configuration for macOS ≤13"
  
  # Check if already configured
  if grep -q "pam_tid.so" "$SUDO_PATH" 2>/dev/null; then
    echo "$readable_name seems to be enabled already"
    return 0
  fi
  
  # Add TouchID to sudo file using sed
  local nl=$'\n'
  local touch_pam_line="$PAM_TOUCHID"
  
  if [[ "$include_reattach" == "true" ]] && check_reattach_available; then
    # Insert both pam_reattach and pam_tid after first comment
    sudo sed -E -i ".bak" "1s/^(#.*)$/\1\\${nl}$PAM_REATTACH\\${nl}$touch_pam_line/" "$SUDO_PATH"
  else
    # Insert only pam_tid after first comment
    sudo sed -E -i ".bak" "1s/^(#.*)$/\1\\${nl}$touch_pam_line/" "$SUDO_PATH"
  fi
  
  echo "Created a backup file at $SUDO_PATH.bak"
  echo
  echo "$readable_name enabled successfully."
  
  return 0
}

check_reattach_available() {
  [[ -f "$PAM_REATTACH_PATH" ]]
}

sudo_touchid_install() {
  local include_reattach="$1"
  local major_version
  major_version=$(detect_os_version)
  
  # Check for migration from legacy configuration
  if check_legacy_configuration; then
    echo "Legacy TouchID configuration detected. Migrating to new secure method..."
    if migrate_legacy_configuration; then
      # After migration, verify legacy configuration is removed
      if check_legacy_configuration; then
        echo "Error: Legacy configuration still detected after migration. Aborting to prevent infinite loop."
        return 1
      else
        echo "Migration completed. Re-running installation with new method..."
        sudo_touchid_install "$include_reattach"
        return $?
      fi
    else
      return 1
    fi
  fi
  
  # Check if already installed
  if [[ "$major_version" -ge 14 && -f "$SUDO_LOCAL_PATH" ]]; then
    # Check if user wants pam_reattach but it's not installed
    if [[ "$include_reattach" == "true" ]] && check_reattach_available && ! grep -q "pam_reattach.so" "$SUDO_LOCAL_PATH" 2>/dev/null; then
      echo "$readable_name is installed but without pam_reattach support."
      echo "Please run --disable first, then reinstall with --with-reattach."
      return 1
    fi
    echo "$readable_name appears to be already installed."
    return 0
  elif [[ "$major_version" -lt 14 ]] && grep -q "pam_tid.so" "$SUDO_PATH" 2>/dev/null; then
    # Check if user wants pam_reattach but it's not installed
    if [[ "$include_reattach" == "true" ]] && check_reattach_available && ! grep -q "pam_reattach.so" "$SUDO_PATH" 2>/dev/null; then
      echo "$readable_name is installed but without pam_reattach support."
      echo "Please run --disable first, then reinstall with --with-reattach."
      return 1
    fi
    echo "$readable_name appears to be already installed."
    return 0
  fi
  
  # Check for pam_reattach if requested
  if [[ "$include_reattach" == "true" ]] && ! check_reattach_available; then
    echo "Warning: pam_reattach.so not found at $PAM_REATTACH_PATH"
    echo "Install it with: brew install pam-reattach"
    echo "Continuing without pam_reattach..."
    include_reattach="false"
  fi
  
  if [[ "$major_version" -ge 14 ]]; then
    sudo_touchid_pamlocal_install "$include_reattach"
  else
    sudo_touchid_legacy_install "$include_reattach"
  fi
}

sudo_touchid_disable() {
  local major_version
  major_version=$(detect_os_version)
  
  # Check what configurations exist
  local has_config=0
  
  if [[ -f "$SUDO_LOCAL_PATH" ]] || [[ -f "$LEGACY_PAM_FILE" ]] || grep -q "pam_tid.so" "$SUDO_PATH" 2>/dev/null; then
    has_config=1
  fi
  
  if [[ $has_config -eq 0 ]]; then
    echo "$readable_name seems to be already disabled"
    return 0
  fi
  
  # Show what will be removed
  echo "The following TouchID configurations will be removed:"
  echo
  
  if [[ -f "$SUDO_LOCAL_PATH" ]]; then
    echo "  - $SUDO_LOCAL_PATH"
  fi
  
  if [[ -f "$LEGACY_PAM_FILE" ]]; then
    echo "  - $LEGACY_PAM_FILE"
  fi
  
  if grep -q "pam_tid.so" "$SUDO_PATH" 2>/dev/null; then
    echo "  - TouchID line from $SUDO_PATH"
    echo
    echo "Your $SUDO_PATH will look like this after removal:"
    echo "----------------------------------------"
    grep -v "pam_tid.so" "$SUDO_PATH" | grep -v "pam_reattach.so"
    echo "----------------------------------------"
  fi
  
  wait_for_user
  
  # Now proceed with removal
  local files_removed=0
  
  # Remove sudo_local file (macOS 14+)
  if [[ -f "$SUDO_LOCAL_PATH" ]]; then
    sudo rm -f "$SUDO_LOCAL_PATH"
    echo "Removed $SUDO_LOCAL_PATH"
    files_removed=$((files_removed + 1))
  fi
  
  # Remove legacy PAM file
  if [[ -f "$LEGACY_PAM_FILE" ]]; then
    sudo rm -f "$LEGACY_PAM_FILE"
    echo "Removed $LEGACY_PAM_FILE"
    files_removed=$((files_removed + 1))
  fi
  
  # Check for legacy configuration in /etc/pam.d/sudo
  if grep -q "pam_tid.so\|pam_reattach.so" "$SUDO_PATH" 2>/dev/null; then
    sudo cp "$SUDO_PATH" "$SUDO_PATH.bak"
    sudo sed -i '.bak' '/pam_tid\.so/d' "$SUDO_PATH"
    sudo sed -i '.bak' '/pam_reattach\.so/d' "$SUDO_PATH"
    echo "Removed TouchID configuration from $SUDO_PATH (backup saved as $SUDO_PATH.bak)"
    files_removed=$((files_removed + 1))
  fi
  
  echo
  echo "$readable_name has been disabled."
}


sudo_touchid() {
  local include_reattach="false"
  local action="install"
  
  for opt in "${@}"; do
    case "$opt" in
    -v | --version)
      echo "v$VERSION"
      return 0
      ;;
    -d | --disable)
      action="disable"
      ;;
    --with-reattach)
      include_reattach="true"
      ;;
    --migrate)
      action="migrate"
      ;;
    -h | --help)
      usage
      return 0
      ;;
    *)
      echo "Unknown option: $opt"
      usage
      return 1
      ;;
    esac
  done
  
  case "$action" in
  install)
    sudo_touchid_install "$include_reattach"
    ;;
  disable)
    sudo_touchid_disable
    ;;
  migrate)
    migrate_legacy_configuration
    ;;
  esac
}

sudo_touchid "${@}"
