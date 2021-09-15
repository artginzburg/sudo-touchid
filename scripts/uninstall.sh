#!/bin/sh

sudo_touchid_uninstall() {
  local touch_pam='auth       sufficient     pam_tid.so'
  local sudo_path='/etc/pam.d/sudo'

  if grep -e "^$touch_pam$" "$sudo_path" &> /dev/null; then
    echo "The following will be your $sudo_path after uninstallation:\n"
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
sudo_touchid_uninstall
