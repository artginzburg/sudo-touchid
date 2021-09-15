#!/bin/sh

VERSION=0.2

sudo_touchid_disable() {
  local touch_pam='auth       sufficient     pam_tid.so'
  local sudo_path='/etc/pam.d/sudo'

  if grep -e "^$touch_pam$" "$sudo_path" &> /dev/null; then
    echo "The following will be your $sudo_path after disabling:\n"
    grep -v "^$touch_pam$" "$sudo_path"
    echo
    read -p "Are you sure? [y] to confirm " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      sudo sed -i '.bak' -e "/^$touch_pam$/d" "$sudo_path"
    fi
  else 
    echo "TouchID for sudo seems not to be enabled"
  fi
}

sudo_touchid() {
  local touch_pam='auth       sufficient     pam_tid.so'
  local sudo_path='/etc/pam.d/sudo'

  for opt in "${@}"; do
    case "$opt" in
      -V|--version)
        echo "$VERSION"
        return 0
      ;;
      -D|--disable)
        sudo_touchid_disable
        return 0
      ;;
    esac
  done

  grep -e "^$touch_pam$" "$sudo_path" &> /dev/null
  if [ $? -ne 0 ]; then
    sudo sed -E -i '.bak' "1s/^(#.*)$/\1\n$touch_pam/" "$sudo_path"
  fi
}
sudo_touchid "${@}"
