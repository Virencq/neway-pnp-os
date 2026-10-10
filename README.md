# Neway PnP OS

A minimal Debian-based x86-64 live image prototype for Neway pick-and-place machines.

## Target platform

- **CPU:** Intel/AMD x86-64 (Debian `amd64`)
- **Storage:** SATA SSD or NVMe SSD
- **Phase 1:** minimal Xorg + Openbox base OS that boots without installing OpenPnP
- **Image strategy:** Debian Live `live-build` prototype first; a persistent SSD installation is a later milestone

## Current implementation

The active development branch contains:

- Debian Trixie amd64 live-build configuration and GitHub Actions ISO build workflow.
- A minimal X11/Openbox environment with a dedicated unprivileged `neway` operator account and tty1 autologin.
- No OpenPnP source checkout, Maven build, or OpenPnP installation in the base ISO.
- A Debian Trixie container build intended to use the distribution's unmodified `live-build` package.
- Initial validation scripts and milestone checklist.

**Status: implementation in progress; ISO build and UEFI VM boot are not yet verified.** This is not production-ready and has not been validated against Neway's real controller or cameras.

## Build and test

See [boot-to-OpenPnP prototype notes](docs/boot-to-openpnp.md) and [Codespaces/GitHub Actions build instructions](docs/codespaces-build.md). OpenPnP installation is a separate later milestone. A successful ISO build is only the first gate; the ISO must then boot in a UEFI VM and pass the checklist in `tests/milestone-1-checklist.md`.

## Design constraints

1. **Separate milestones.** The base OS ISO must build and boot independently of OpenPnP.
2. **Least privilege.** The operator runs as `neway`, not root.
3. **Persistence.** A live ISO normally discards session changes on reboot unless persistence is configured. Configuration persistence and a production SSD installation path remain open work.
4. **Hardware compatibility is empirical.** USB/serial controller, camera capture, display and extended-run tests must be performed on the actual machine.

## Official references

- [Debian Live Manual](https://live-team.pages.debian.net/live-manual/)
- [Debian live-build package](https://packages.debian.org/stable/live-build)
- [OpenPnP releases](https://github.com/openpnp/openpnp/releases)
- [OpenPnP Quick Start](https://github.com/openpnp/openpnp/wiki/Quick-Start)
- [OpenPnP source repository](https://github.com/openpnp/openpnp)

## Licensing

OpenPnP is GPL-3.0 licensed. Review [LICENSES.md](LICENSES.md) and upstream notices before redistribution.
