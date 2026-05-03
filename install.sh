#!/bin/sh
set -e

script_url="https://raw.githubusercontent.com/artginzburg/sudo-touchid/main/sudo-touchid.sh"
plist_url="https://raw.githubusercontent.com/artginzburg/sudo-touchid/main/com.user.sudo-touchid.plist"
bin_path="/usr/local/bin/sudo-touchid"
plist_path="/Library/LaunchDaemons/com.user.sudo-touchid.plist"

script_tmp="$(mktemp "${TMPDIR:-/tmp}/sudo-touchid.XXXXXX")"
plist_tmp="$(mktemp "${TMPDIR:-/tmp}/sudo-touchid.plist.XXXXXX")"

cleanup() {
  rm -f "$script_tmp" "$plist_tmp"
}
trap cleanup EXIT INT TERM

curl -fL -# "$script_url" -o "$script_tmp"
curl -fL -# "$plist_url" -o "$plist_tmp"

sudo install -d -o root -g wheel -m 755 "$(dirname "$bin_path")"
sudo install -o root -g wheel -m 755 "$script_tmp" "$bin_path"
sudo install -o root -g wheel -m 644 "$plist_tmp" "$plist_path"

"$bin_path"
