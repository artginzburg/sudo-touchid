#!/bin/bash

VERSION=0.3
readable_name='[TouchID for sudo]'
backup_ext='.bak'

touch_pam='auth       sufficient     pam_tid.so'
sudo_path='/etc/pam.d/sudo'

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

sudo_touchid_is_enabled() {
  grep -q -e "^$touch_pam$" "$sudo_path"
}

sudo_touchid_disable() {
  if sudo_touchid_is_enabled; then
    echo "The following will be your $sudo_path after disabling:"
    echo
    grep -v "^$touch_pam$" "$sudo_path"
    wait_for_user
    if sudo sed -i "$backup_ext" -e "/^$touch_pam$/d" "$sudo_path"; then
      echo "$readable_name has been disabled."
    else
      echo "$readable_name failed to disable"
    fi
  else
    echo "$readable_name seems to be already disabled"
  fi
}

sudo_touchid_enable() {
  if ! sudo_touchid_is_enabled; then
    if sudo sed -E -i "$backup_ext" "1s/^(#.*)$/\1\n$touch_pam/" "$sudo_path"; then
      echo "$readable_name enabled successfully."
    else
      echo "$readable_name failed to execute"
    fi
  else
    echo "$readable_name seems to be enabled already"
  fi
}

sudo_touchid() {
  for opt in "${@}"; do
    case "$opt" in
    -V | --version)
      echo "$VERSION"
      return 0
      ;;
    -D | --disable)
      sudo_touchid_disable
      return 0
      ;;
    *)
      echo "$readable_name Unknown option: $opt"
      return 0
      ;;
    esac
  done

  sudo_touchid_enable
}

sudo_touchid "${@}"
