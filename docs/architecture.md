# Architecture Decision Record: Neway PnP OS v1

**Status:** Proposed for Milestone 1  
**Target:** Intel/AMD x86-64 mini PC or industrial PC, SATA/NVMe SSD  
**Decision owner:** Neway

## Decision

Build the first prototype as a minimal Debian-based x86-64 image using the official Debian Live `live-build` tooling. Run OpenPnP in a dedicated, automatically started graphical session with no full desktop environment.

## Why Debian minimal first

- OpenPnP is a Java GUI application, so a graphical server is required even if no desktop environment is shown.
- OpenPnP's official repository documents bundled OpenCV binaries for Linux x86/x64. A pinned, tested upstream archive is preferable to building/forking OpenPnP as part of the OS image.
- Debian provides maintained kernel, USB/serial, udev, graphics and package infrastructure.
- `live-build` supports repeatable image configuration and ISO output. The first deliverable is a prototype ISO for VM and spare-PC validation, not yet a production SSD installer.

## Session model

1. Boot Linux normally with systemd.
2. Start a dedicated unprivileged `neway` operator session.
3. Start the minimum supported X11 session and launch the pinned OpenPnP archive.
4. Restart OpenPnP after an application crash, with bounded retries and logs.
5. Keep a documented maintenance route for diagnostics and image recovery.

Do not use a root-owned OpenPnP process. Do not disable system services merely to reduce the package count until hardware testing confirms they are unnecessary.

## Artifact pinning

The OpenPnP artifact must have all of:
- Official source/release URL
- Exact release or snapshot identifier
- SHA-256 checksum committed to versioned metadata
- License/source-notice review

The build must fail closed when the artifact version, URL, or checksum is missing or does not match. Never silently build from an unpinned “latest” URL.

## Persistent machine data

Machine configuration, calibration, jobs, and logs must live in a documented persistent data directory and be excluded from image replacement/update operations. The first live ISO is a boot prototype; persistence behavior must be explicitly tested and must not be assumed.

## Deferred decisions

- Exact Debian codename and kernel package set after checking current support.
- Exact OpenPnP release and Java runtime compatibility.
- X11 session implementation and whether a window manager is needed for the chosen OpenPnP version.
- Final installed-to-SSD image/installer mechanism.
- Real hardware-specific camera, USB serial, touchscreen and GPU requirements.

## References

- [OpenPnP Quick Start](https://github.com/openpnp/openpnp/wiki/Quick-Start)
- [OpenPnP source repository](https://github.com/openpnp/openpnp)
- [Debian Live Manual](https://live-team.pages.debian.net/live-manual/)
- [Debian live-build package](https://packages.debian.org/stable/live-build)
