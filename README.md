<img height="128" src="res/icon.png" alt="Icon" align="left" />

# sudo-touchid

[![Downloads](https://img.shields.io/github/downloads/artginzburg/sudo-touchid/total?color=teal)](https://github.com/artginzburg/sudo-touchid/releases)
[![Donate](https://img.shields.io/badge/buy%20me%20a%20coffee-donate-white)](https://github.com/artginzburg/sudo-touchid?sponsor=1)

<div align="right">

Native and reliable [**TouchID**](https://support.apple.com/en-gb/guide/mac-help/mchl16fbf90a/mac) support for `sudo`

</div>

## Try it out <sub> &nbsp; <sup> &nbsp; without installing</sup></sub>

```powershell
curl -sL git.io/sudo-touch-id | sh
```

Now `sudo` is great, just like Safari — with your fingerprint in Terminal.

> <sup>Don't worry, you can also [reverse](#usage) it</sup>

<div align="center">

<sub><sub>Result:</sub></sub>

<img alt="Preview" src="./res/preview.png" width="500vmin" />

<sub>Just type <a href="https://git.io/sudotouchid"><code>git.io/sudotouchid</code></a> to go here.</sub>

</div>

### Features

- Fast & reliable
- Written in Bash — no dependencies
- **pam_reattach support** for tmux/screen compatibility (GUI session reattachment)
- **Supports modern and legacy systems:** For macOS 13 and below, see [LEGACY_MACOS.md][legacy]

<br />

## Install

### Via [🍺 Homebrew](https://brew.sh/)

```bash
brew install artginzburg/tap/sudo-touchid
```

> Check out [the formula](https://github.com/artginzburg/homebrew-tap/blob/main/Formula/sudo-touchid.rb) if you're interested

<br />

## Usage

Copy and run this command:

```bash
sudo-touchid
```

It adds TouchID to sudo configuration, or migrates an existing legacy configuration if you're upgrading from macOS 13 or below.

```bash
# Usage:
sudo-touchid [options]
             [-v,  --version]   # Output installed version
             [-d,  --disable]   # Remove TouchID from sudo config
             [--with-reattach]  # Include pam_reattach.so for tmux/screen support
             [--migrate]        # Migrate from legacy configuration
             [--verbose]        # Show detailed output
             [-q,  --quiet]     # Show minimal output (errors only)
```

if not installed, can be used via [`curl`][curl] <sup>bundled with macOS</sup>

```bash
sh <( curl -sL git.io/sudo-touch-id )
```

> Accepts the same arguments, like -d or -v.

<br />

### Why?

- **Productivity:** Automates TouchID setup
- **Lightweight:** Small Bash script, no builds or Xcode required
- **Reliable:** Persistent configuration across system updates

<br />

## How does it work?

**For macOS 14+:**

- Creates `/etc/pam.d/sudo_local` with TouchID configuration
- Never modifies system-managed `/etc/pam.d/sudo` file

**All versions:**

- Has a `--disable` (`-d`) option that removes all TouchID configurations.
- Optional `--with-reattach` for GUI session reattachment support
- Creates backup files during migration
- Automatically detects and migrates legacy configurations

### Manual installation

Just save `sudo-touchid.sh` as `/usr/local/bin/sudo-touchid` with execute permissions

> See [LEGACY_MACOS.md][legacy] for additional considerations on older systems

<br />

## Related

- **tmux/screen support:** [pam_reattach](https://github.com/fabianishere/pam_reattach) module (built-in via `--with-reattach`)
- **Apple Watch support:** [pam_watchid](https://github.com/biscuitehh/pam-watchid) module
- **Disable password prompt:** Change `%admin ALL=(ALL) ALL` to `%admin ALL=(ALL) NOPASSWD: ALL` in `/etc/sudoers`

[curl]: https://curl.se
[legacy]: ./docs/LEGACY_MACOS.md
