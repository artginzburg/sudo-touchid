#!/bin/bash

VERSION=0.4
readable_name='[TouchID for sudo]'
executable_name='sudo-touchid'

usage() {
  cat <<EOF

  Usage: $executable_name [options]
    Running without options adds TouchID parameter to sudo configuration

  Options:
    -d,  --disable     Remove TouchID from sudo config

    -v,  --version     Output version
    -h,  --help        This message.

EOF
}

backup_ext='.bak'

touch_pam='auth       sufficient     pam_tid.so'
sudo_path='/etc/pam.d/sudo'

nl=$'\n'

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

display_backup_info() {
  echo "Created a backup file at $sudo_path$backup_ext"
  echo
}

display_sudo_without_touch_pam() {
  grep -v "^$touch_pam$" "$sudo_path"
}

touch_pam_at_sudo_path_check_exists() {
  grep -q -e "^$touch_pam$" "$sudo_path"
}

touch_pam_at_sudo_path_insert() {
  sudo /usr/bin/sed -E -i "$backup_ext" "1s/^(#.*)$/\1\\${nl}$touch_pam/" "$sudo_path"
}

touch_pam_at_sudo_path_remove() {
  sudo /usr/bin/sed -i "$backup_ext" -e "/^$touch_pam$/d" "$sudo_path"
}

sudo_touchid_disable() {
  if touch_pam_at_sudo_path_check_exists; then
    echo "The following will be your $sudo_path after disabling:"
    echo
    display_sudo_without_touch_pam
    wait_for_user
    if touch_pam_at_sudo_path_remove; then
      display_backup_info
      echo "$readable_name has been disabled."
    else
      echo "$readable_name failed to disable"
    fi
  else
    echo "$readable_name seems to be already disabled"
  fi
}

sudo_touchid_enable() {
  if touch_pam_at_sudo_path_check_exists; then
    echo "$readable_name seems to be enabled already"
  else
    if touch_pam_at_sudo_path_insert; then
      display_backup_info
      echo "$readable_name enabled successfully."
    else
      echo "$readable_name failed to execute"
    fi
  fi
}

sudo_touchid() {
  for opt in "${@}"; do
    case "$opt" in
    -v | --version)
      echo "v$VERSION"
      return 0
      ;;
    -d | --disable)
      sudo_touchid_disable
      return 0
      ;;
    -h | --help)
      usage
      return 0
      ;;
    *)
      echo "Unknown option: $opt"
      usage
      return 0
      ;;
    esac
  done

  sudo_touchid_enable
}

sudo_touchid "${@}"
