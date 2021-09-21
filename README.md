<div align="center">

<img height="80" src="misc/icon.png" />

### sudo-touchid

Permanent [**TouchID**](https://support.apple.com/en-gb/guide/mac-help/mchl16fbf90a/mac) support for `sudo`
  
![Preview](misc/preview.png)

<sub>Just type <a href="https://git.io/sudotouchid"><code>git.io/sudotouchid</code></a> to go here.</sub>
            
</div>

## Try it out <sub> &nbsp; <sup> &nbsp; without installing</sup></sub>

```powershell
curl -sL git.io/sudo-touch-id | sh
```

> Now entering sudo mode is easier than ever, just like on GitHub — with TouchID in Terminal or whatever you're on. <sup>Don't worry, you can also [reverse](#reverse-without-installation) it without installing</sup>

### Why?

Productivity · reliability — macOS _updates_ do _reset_ `/etc/pam.d/sudo`, so previously users had to _manually_ edit the file after each upgrade.

This tool was born to automate the process, allowing for TouchID sudo auth to be **quickly enabled** on a new/clean system.

<br />

## Install <a href="https://github.com/artginzburg/sudo-touchid/releases"><img align="right" src="https://img.shields.io/github/downloads/artginzburg/sudo-touchid/total?label=downloads" /></a>

### Via [🍺 Homebrew](https://brew.sh/)

```powershell
brew install artginzburg/tap/sudo-touchid
sudo brew services start sudo-touchid
```

> Check out [the formula](https://github.com/artginzburg/homebrew-tap/blob/main/Formula/sudo-touchid.rb) if you're interested

### Using `curl`

```powershell
curl -sL git.io/sudo-touchid | sh
```

> Performs automated "manual" installation. But `brew install` is still the recommended way.

<br />

## What does it do?

#### `sudo-touchid.sh` — the script:

- Adds `auth sufficient pam_tid.so` to the top of `/etc/pam.d/sudo` file <sup>following [@cabel's advice](https://twitter.com/cabel/status/931292107372838912)</sup>

- Creates a backup file named `sudo.bak`.

- Has a `--disable` (`-D`) option that performs the opposite of the steps above.

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

### Why this?

Fast · [Reversible](#reverse-without-installation) · Reliable

> Unlike other solutions, this can be included to your automated system build with `brew install artginzburg/tap/sudo-touchid && sudo brew services start sudo-touchid`. Always working, always up to date with major macOS upgrades!

Also, the script is small, doesn't need any builds, doesn't need XCode.

Take a look at code size comparison of the previously favoured solution to the one you're currently reading:

[![](https://img.shields.io/github/languages/code-size/mattrajca/sudo-touchid?color=critical&label=mattrajca/sudo-touchid%20code%20size)](https://github.com/mattrajca/sudo-touchid)
![](https://img.shields.io/github/languages/code-size/artginzburg/sudo-touchid?color=success&label=artginzburg/sudo-touchid%20code%20size)

that is about 6718 times difference.

<br />

### Reverse without installation

```ps1
sh <( curl -sL git.io/sudo-touch-id ) -D
```

<br />

### Contributing

##### [PRs](https://github.com/artginzburg/sudo-touchid/pulls) and [Issues](https://github.com/artginzburg/sudo-touchid/issues/new/choose) are much welcome!
If you don't like something — change it or inform the ones willing to help.

### Related

#### Disabling password prompt for `sudo`

- Change `%admin ALL=(ALL) ALL` to `%admin ALL=(ALL) NOPASSWD: ALL` in `/etc/sudoers`
