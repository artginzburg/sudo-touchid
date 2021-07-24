#!/bin/sh

sudo_touchid() {
  local touch_pam='auth       sufficient     pam_tid.so'
  local sudo_path='/etc/pam.d/sudo'

  grep -e "^$touch_pam$" "$sudo_path" &> /dev/null
  if [ $? -ne 0 ]; then
    sudo sed -E -i '.bak' "1s/^(#.*)$/\1\n$touch_pam/" "$sudo_path"
  fi
}
sudo_touchid
