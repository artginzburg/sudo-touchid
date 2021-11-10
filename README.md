<img height="128" src="res/icon.png" alt="Icon" align="left" />

# sudo-touchid

[![Downloads](https://img.shields.io/github/downloads/artginzburg/sudo-touchid/total?color=teal)](https://github.com/artginzburg/sudo-touchid/releases)
[![Donate](https://img.shields.io/badge/buy%20me%20a%20coffee-donate-white)](https://github.com/artginzburg/sudo-touchid?sponsor=1)

<div align="right">

Permanent [**TouchID**](https://support.apple.com/en-gb/guide/mac-help/mchl16fbf90a/mac) support for `sudo`

</div>

## Try it out <sub> &nbsp; <sup> &nbsp; without installing</sup></sub>

```powershell
curl -sL git.io/sudo-touch-id | sh
```

Now sudo is great, just like Safari — with your fingerprint in Terminal or whatever you're on.

> <sup>Don't worry, you can also [reverse](#usage) it without installing</sup>

<div align="center">

<sub><sub>Result:</sub></sub>

<img alt="Preview" src="./res/preview.png" width="500vmin" />

<sub>Just type <a href="https://git.io/sudotouchid"><code>git.io/sudotouchid</code></a> to go here.</sub>

</div>

## Features

- Fast
- Reliable
- Written in Bash — no dependencies!
- Include it to your automated system build — always working, always up to date with major macOS upgrades!

## Install

### Via [🍺 Homebrew](https://brew.sh/) (Recommended)

```powershell
brew install artginzburg/tap/sudo-touchid
sudo brew services start sudo-touchid
```

> Check out [the formula](https://github.com/artginzburg/homebrew-tap/blob/main/Formula/sudo-touchid.rb) if you're interested

### Using `curl`

```powershell
curl -sL git.io/sudo-touchid | sh
```

> Performs automated "manual" installation.

## Usage

```ps1
sudo-touchid [options]
           # Running without options adds TouchID parameter to sudo configuration
             [-v,  --version]   # Output installed version
           # Commands:
             [-d,  --disable]   # Removes TouchID from sudo config
```

if not installed, can be used via `curl`

```ps1
sh <( curl -sL git.io/sudo-touch-id ) [options]
                                    # Reliability — check :)
                                      [-d,  --disable]   # Removes TouchID from sudo config
```

<br />

### Why?

1. Productivity

   macOS _updates_ do _reset_ `/etc/pam.d/sudo`, so previously users had to _manually_ edit the file after each upgrade.

   > This tool was born to automate the process, allowing for TouchID sudo auth to be **quickly enabled** on a new/clean system.

2. Spreading the technology.

   I bet half of you didn't know.

   > It was there for a long time.

3. Lightness

   The script is small, doesn't need any builds, doesn't need XCode.

   ##### Code size comparison — previously favoured solution VS. the one you're currently reading:

   [![](https://img.shields.io/github/languages/code-size/mattrajca/sudo-touchid?color=brown&label=mattrajca/sudo-touchid%20—%20code%20size)](https://github.com/mattrajca/sudo-touchid)

   ![](https://img.shields.io/github/languages/code-size/artginzburg/sudo-touchid?color=teal&label=artginzburg/sudo-touchid%20—%20code%20size)

<br />

## How does it work?

#### `sudo-touchid.sh` — the script:

- Adds `auth sufficient pam_tid.so` to the top of `/etc/pam.d/sudo` file <sup>following [@cabel's advice](https://twitter.com/cabel/status/931292107372838912)</sup>

- Creates a backup file named `sudo.bak`.

- Has a `--disable` (`-d`) option that performs the opposite of the steps above.

<details>
  <summary align="right"><sub>Non-Homebrew files:</sub></summary>
  <br />

#### `com.user.sudo-touchid.plist` — the property list (global daemon):

- Runs `sudo-touchid.sh` on system reload

  > Needed because any following macOS updates just wipe out our custom `sudo`.

#### `install.sh` — the installer:

- Saves `sudo-touchid.sh` as `/usr/local/bin/sudo-touchid` and gives it the permission to execute.

  > (yes, that also means you're able to run `sudo-touchid` from Terminal)

- Saves `com.user.sudo-touchid.plist` to `/Library/LaunchDaemons/` so that it's running on boot (requires root permission).
</details>

<br />

### Manual installation

1. Generally follow the steps provided by the installer in "Non-Homebrew files"
2. If you need to, store `sudo-touchid.sh` anywhere else and replace `/usr/local/bin` in `com.user.sudo-touchid.plist` with the chosen path.

<br />

## Contributing

##### [PRs](https://github.com/artginzburg/sudo-touchid/pulls) and [Issues](https://github.com/artginzburg/sudo-touchid/issues/new/choose) are much welcome!

If you don't like something — change it or inform the ones willing to help.

<br />

## Related

### Disabling password prompt for `sudo`

- Change `%admin ALL=(ALL) ALL` to `%admin ALL=(ALL) NOPASSWD: ALL` in `/etc/sudoers`
