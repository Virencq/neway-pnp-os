# Neway PnP OS

A minimal Debian-based x86-64 live image prototype for Neway pick-and-place machines, designed to boot directly into OpenPnP.

## Target platform

- **CPU:** Intel/AMD x86-64 (Debian `amd64`)
- **Storage:** SATA SSD or NVMe SSD
- **Normal operation:** power on and launch OpenPnP automatically, without a general-purpose desktop environment
- **Graphical runtime:** minimal Xorg + Openbox session; OpenPnP is a GUI application and cannot run without a graphical server
- **Image strategy:** Debian Live `live-build` prototype first; a production SSD installer is a later milestone

## Current implementation

The active development branch contains:

- Debian Trixie amd64 live-build configuration and GitHub Actions ISO build workflow.
- OpenPnP 2.6 source pinned to immutable commit `5bd404cfc70f34103a3ca0fbb6b50c2b465f407c`, compiled in the image build.
- A dedicated unprivileged `neway` account with tty1 autologin and X11 startup.
- Bounded OpenPnP restart behavior and a per-user startup log.
- Initial validation scripts and boot-to-OpenPnP test instructions.

**Status: implementation in progress; ISO build and UEFI VM boot are not yet verified.** This is not production-ready and has not been validated against Neway's real controller or cameras.

## Build and test

See [boot-to-OpenPnP prototype notes](docs/boot-to-openpnp.md) and [Codespaces/GitHub Actions build instructions](docs/codespaces-build.md).

The clean GitHub Actions runner is the authoritative build environment. A successful image build is only the first gate; the ISO must then boot in a UEFI VM and pass the checklist in `tests/milestone-1-checklist.md`.

## Design constraints

1. **Pin sources.** The OpenPnP source commit is immutable; Maven dependency repositories are not yet snapshot-locked, so bit-for-bit reproducibility is not claimed.
2. **Least privilege.** OpenPnP runs as `neway`, not root. Serial and video group access is added only where those groups exist.
3. **No hidden data loss claims.** A live ISO normally discards session changes on reboot unless persistence is explicitly configured. Configuration persistence and a production SSD installation path remain open work.
4. **Recoverability.** Startup logs are stored at `/home/neway/.local/state/neway/openpnp.log`; the launcher stops after repeated failures rather than crashing in an unlimited loop.
5. **Hardware compatibility is empirical.** USB/serial controller, camera capture, OpenCV, display and extended-run tests must be performed on the actual machine.

## Official references

- [Debian Live Manual](https://live-team.pages.debian.net/live-manual/)
- [Debian live-build package](https://packages.debian.org/stable/live-build)
- [OpenPnP 2.6 release](https://github.com/openpnp/openpnp/releases/tag/2.6)
- [OpenPnP Quick Start](https://github.com/openpnp/openpnp/wiki/Quick-Start)
- [OpenPnP source repository](https://github.com/openpnp/openpnp)

## Licensing

OpenPnP is GPL-3.0 licensed. Review [LICENSES.md](LICENSES.md) and the upstream notices before redistribution.
