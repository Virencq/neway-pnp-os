# Neway PnP OS

An embedded-style x86-64 appliance image that boots directly into the official OpenPnP Linux test build. It is not a general-purpose desktop distribution.

## Target

- Intel/AMD x86-64 industrial or mini PC
- UEFI boot, SATA/NVMe SSD
- Debian Trixie minimal root filesystem
- OpenPnP starts automatically in a minimal graphical session
- No editor, office suite, browser, media player, development toolchain, or full desktop environment

## New build direction

The previous Debian Live package-selection approach is retired on this branch. The new design follows the minimal-rootfs and read-only-image approach documented by [debian-minimal-live](https://github.com/carstenandrich/debian-minimal-live), then adds only the graphics and OpenPnP runtime dependencies needed for this appliance.

We use that repository as an upstream design reference, not blindly importing its default image: its default image includes utilities and services Neway does not need.

### Application

Use the latest official OpenPnP Linux test package from:

- [Official test downloads](https://openpnp.org/test-downloads/)
- [Official Linux test .deb](https://s3-us-west-2.amazonaws.com/openpnp/OpenPnP-linux-test.deb)

Because the test URL is mutable, every build must record the downloaded package SHA-256 and package metadata. This makes each generated image identifiable even when the upstream test package changes. Later, the package source can be switched to Neway's customized OpenPnP build without redesigning the base OS.

### Image principles

- Bootstrap Debian with a minimal variant and disable recommended packages unless explicitly justified.
- Install OpenPnP through its Debian package so declared dependencies are resolved by APT.
- Keep build tools out of the target root filesystem.
- Start the graphical session and OpenPnP directly; no display manager or full desktop.
- Run OpenPnP as a dedicated non-root account with only device groups/permissions demonstrated to be necessary.
- Preserve OpenPnP configuration, calibration, job files and logs across OS updates.
- Keep the base OS immutable/read-only where practical, with a defined writable data area.
- Do not remove runtime libraries based only on package size. Validate dependency closure and real camera/controller hardware.

## Status

This branch starts the new implementation from the minimal-appliance direction. A production-ready image is **not yet validated**. UEFI boot, OpenPnP startup, persistence, and Neway camera/controller compatibility must pass tests before deployment.

## Official references

- [Minimal Debian live image builder](https://github.com/carstenandrich/debian-minimal-live)
- [Debian Live Manual](https://live-team.pages.debian.net/live-manual/)
- [OpenPnP test downloads](https://openpnp.org/test-downloads/)
- [OpenPnP source and documentation](https://github.com/openpnp/openpnp)
- [OpenPnP Quick Start](https://github.com/openpnp/openpnp/wiki/Quick-Start)

## Licensing

Review [LICENSES.md](LICENSES.md) and upstream licensing/source obligations before distributing images.
