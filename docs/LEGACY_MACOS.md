# Legacy macOS Support (macOS 13 and below)

> **Note:** For macOS Ventura and prior, full installation is necessary to preserve TouchID for `sudo` through system updates.

## Install

### Via [🍺 Homebrew](https://brew.sh/) (Recommended)

```powershell
brew install artginzburg/tap/sudo-touchid
sudo brew services start sudo-touchid
```

> Check out [the formula](https://github.com/artginzburg/homebrew-tap/blob/main/Formula/sudo-touchid.rb) if you're interested

### Using [`curl`][curl]

```bash
curl -sL git.io/sudo-touchid | sh
```

## How it works

- Adds `auth sufficient pam_tid.so` to the top of `/etc/pam.d/sudo` file (following [@cabel's advice](https://twitter.com/cabel/status/931292107372838912)).
- Creates a backup file named `sudo.bak`.
- Optional `--with-reattach` flag adds `pam_reattach.so` before `pam_tid.so` for tmux/screen support.

## Why?

macOS updates reset `/etc/pam.d/sudo`, so previously users had to manually edit the file after each upgrade. This tool automates the process by:

1. Making the `sudo-touchid` command available.
2. Auto-running on every system launch using a simple [`launchd`](https://www.launchd.info) daemon, so that when a macOS update erases the custom `sudo` configuration, `sudo-touchid` fixes it again.

### Manual installation

1. Save `sudo-touchid.sh` as `/usr/local/bin/sudo-touchid` with execute permissions
2. Save `com.user.sudo-touchid.plist` to `/Library/LaunchDaemons/` for auto-run on boot
3. Customize paths in the `.plist` file if needed

[curl]: https://curl.se
