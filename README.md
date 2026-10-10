# Neway PnP OS

A minimal, reproducible Linux image for Neway x86-64 pick-and-place machines, designed to boot directly into OpenPnP.

## Target platform

- **CPU:** Intel/AMD x86-64 (Debian `amd64`)
- **Storage:** SATA SSD or NVMe SSD
- **User experience:** Power on and launch OpenPnP automatically; no general-purpose desktop shell
- **Initial image strategy:** Debian minimal base with a small X11 session for OpenPnP's GUI. “No desktop” means no full desktop environment, not no graphical server.
- **Build system candidate:** Debian Live `live-build` for the first reproducible bootable prototype. Evaluate an installed-to-SSD image path after the first boot test.

## Project goals

- Run OpenPnP reliably with only its required operating-system and hardware dependencies.
- Preserve machine configuration, calibration, job files, and logs across OS updates.
- Produce versioned, repeatable images with documented build steps and validation.
- Keep upstream OpenPnP separate; pin a tested upstream release/archive and verify its SHA-256 checksum.
- Keep maintenance/recovery access available without making the normal operator experience a desktop.

## Status

**Milestone 1: architecture and build foundation.** The repository documents the target platform and acceptance criteria. A bootable image has not yet been built or hardware-tested.

## Design principles

1. **Compatibility before size.** Validate USB/serial motion-controller access, camera/OpenCV support, graphics acceleration, and the required Java runtime before removing packages.
2. **Reproducible builds.** Pin the Debian release, OpenPnP archive and SHA-256, and build-tool versions where practical.
3. **Safe persistence.** Keep machine configuration, calibration, job files, and logs outside replaceable OS files. Never overwrite them during an OS update.
4. **Recoverability.** Provide logs, a maintenance path, and documented recovery/reflash instructions.
5. **Least privilege.** Run OpenPnP as a dedicated non-root user; grant only required device permissions.
6. **No false minimalism.** Do not remove USB rules, camera libraries, fonts, networking, or services until hardware tests prove they are unnecessary.

## Repository layout

- `image/` — Debian live-build configuration
- `packages/openpnp/` — pinned upstream artifact metadata
- `system/` — kiosk, service, permissions, and persistence configuration
- `scripts/` — build and validation scripts
- `tests/` — automated checks and hardware acceptance tests
- `docs/` — architecture, build instructions, recovery, and release criteria

## Build strategy

Use Debian's official `live-build` tooling to produce the first x86-64 bootable prototype. Install only a minimal X server and the components needed by OpenPnP; launch the application directly from the session without GNOME, KDE, or another full desktop environment. OpenPnP is a GUI application, so a graphical server and compatible graphics libraries are still required.

OpenPnP is written in Java and bundles OpenCV binaries for Linux x86/x64 according to its official project documentation. The exact Java runtime must be selected against the pinned OpenPnP release, not guessed from old wiki text. See [OpenPnP Quick Start](https://github.com/openpnp/openpnp/wiki/Quick-Start), [OpenPnP source](https://github.com/openpnp/openpnp), and the [Debian Live Manual](https://live-team.pages.debian.net/live-manual/).

## Milestone 1 — Reproducible boot-to-OpenPnP prototype

**Goal:** produce a bootable x86-64 image that starts OpenPnP automatically in a minimal graphical session.

Acceptance criteria:
- Build configuration and scripts are committed to GitHub.
- OpenPnP archive is pinned by version/source URL and verified SHA-256.
- A clean build produces an ISO and checksum manifest.
- ISO boots in a VM to OpenPnP without manual login or desktop navigation.
- Logs are accessible if startup fails.
- A maintenance/recovery path is documented.
- VM smoke tests pass before hardware claims are made.

**Not yet in scope:** production-ready SSD installer, automatic updates, machine-specific calibration, and validation of Neway's real motion controller/cameras. Those require a successful prototype and the actual hardware.

## Hardware acceptance before production

- Successful boot to OpenPnP without manual launch steps.
- Verified motion-controller connectivity and sustained machine operation.
- Verified camera capture and vision processing with actual camera hardware.
- Configuration and calibration survive reboot and OS update.
- OpenPnP restart and system recovery are tested.
- Image checksum, version, build inputs, known limitations, and reflash instructions are published.

## Licensing

OpenPnP and every bundled dependency retain their own licenses and notices. Before distributing a Neway image, record exact versions, license texts, source-availability obligations, and required attributions in [LICENSES.md](LICENSES.md).
