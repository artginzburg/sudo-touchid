#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
installer="$repo_root/install.sh"

if ! grep -Eq 'bin_path="/usr/local/bin/sudo-touchid"' "$installer"; then
  echo "install.sh must keep the sudo-touchid executable path explicit" >&2
  exit 1
fi

if ! grep -Eq 'plist_path="/Library/LaunchDaemons/com.user.sudo-touchid.plist"' "$installer"; then
  echo "install.sh must keep the LaunchDaemon plist path explicit" >&2
  exit 1
fi

if ! grep -Eq 'sudo[[:space:]]+install[[:space:]].*-o[[:space:]]+root[[:space:]].*-g[[:space:]]+wheel[[:space:]].*-m[[:space:]]+755[[:space:]].*"\$bin_path"' "$installer"; then
  echo "install.sh must install /usr/local/bin/sudo-touchid as root:wheel mode 755" >&2
  exit 1
fi

if ! grep -Eq 'sudo[[:space:]]+install[[:space:]].*-o[[:space:]]+root[[:space:]].*-g[[:space:]]+wheel[[:space:]].*-m[[:space:]]+644[[:space:]].*"\$plist_path"' "$installer"; then
  echo "install.sh must install the LaunchDaemon plist as root:wheel mode 644" >&2
  exit 1
fi

if grep -Eq 'curl.*-o[[:space:]]+/usr/local/bin/sudo-touchid|chmod[[:space:]]+\+x[[:space:]]+/usr/local/bin/sudo-touchid' "$installer"; then
  echo "install.sh must not write the daemon target directly as the invoking user" >&2
  exit 1
fi
