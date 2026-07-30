# Security Policy

## Supported Versions

Only the latest release is supported. If you found an issue, please check that it reproduces on the current version first.

## Reporting a Vulnerability

`sudo-touchid` modifies your system's sudo authentication config (`/etc/pam.d/sudo_local`), so please **do not open a public issue** for anything that could weaken or bypass authentication.

Instead, use GitHub's private vulnerability reporting:
**[Report a vulnerability](https://github.com/artginzburg/sudo-touchid/security/advisories/new)**

You'll get a response as soon as possible — this is a solo-maintained project, so there's no formal SLA, but reports about `sudo`/PAM behavior are top priority.

## Scope

In scope: anything in this repo — the script itself, the install flow (`install.sh`, `curl | sh`), the Homebrew formula, the launchd plist.
Out of scope: bugs in `pam_tid.so` / `pam_reattach.so` themselves (report those to Apple / [fabianishere/pam_reattach](https://github.com/fabianishere/pam_reattach)).
