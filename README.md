# Neway PnP OS

A minimal, reproducible Linux image for Neway pick-and-place machines, designed to boot directly into OpenPnP.

## Project goals

- Run OpenPnP reliably with only its required operating-system and hardware dependencies.
- Boot into a dedicated machine interface rather than a general-purpose desktop.
- Preserve machine configuration, calibration, job files, and logs across OS updates.
- Produce versioned, repeatable images with documented build steps and validation.
- Keep upstream OpenPnP separate; pin a tested upstream release or commit rather than maintaining an unnecessary fork.

## Status

**Initial planning.** Target CPU architecture and board are not yet specified. Do not select an image builder, kernel configuration, Java version, or graphics stack until the target hardware and OpenPnP release are confirmed.

## Design principles

1. **Compatibility before size.** Validate USB/serial motion-controller access, camera/OpenCV support, graphics acceleration, and the required Java runtime before removing packages.
2. **Reproducible builds.** Pin base image, package versions where practical, OpenPnP release/commit, and build-tool versions.
3. **Safe updates.** Keep machine data separate from the immutable or replaceable OS image. Never overwrite calibration or job data during an OS update.
4. **Recoverability.** Provide logs, a maintenance mode, and a documented recovery/reflash process.
5. **Least privilege.** Run OpenPnP as a dedicated non-root user; grant only the device permissions it needs.
6. **No false minimalism.** Do not remove networking, USB rules, camera libraries, fonts, audio/desktop components, or services until hardware tests prove they are unnecessary.

## Planned repository layout

- `image/` — image build configuration and build entry points
- `packages/openpnp/` — pinned OpenPnP version and packaging/launch integration
- `system/` — service, kiosk, permissions, recovery, and persistence configuration
- `scripts/` — build, validation, and image verification scripts
- `tests/` — automated checks and hardware acceptance test definitions
- `docs/` — architecture, build instructions, recovery, and release checklist

Directories will be added with the first implementation milestone; this README does not imply those components already exist.

## Build strategy

The initial candidate is a minimal Debian-based image with a lightweight graphical session and automatic OpenPnP launch. Evaluate Buildroot or Yocto only after confirming the target architecture and proving that the chosen Java, graphics, camera, and USB stack can run OpenPnP. The final choice must be based on a working hardware prototype, not image size alone.

## Acceptance criteria

A release is not production-ready until it demonstrates:

- Repeatable image build from a clean environment.
- Successful boot to OpenPnP without manual login or launching steps.
- Verified motion-controller connectivity and sustained machine operation.
- Verified camera capture and vision processing for the actual camera hardware.
- Configuration and calibration survive reboot and OS update.
- OpenPnP restart and system recovery are tested.
- Image checksum, version, build inputs, known limitations, and reflash instructions are published.

## Hardware and release decisions still required

- Target computer/board and CPU architecture (x86-64 or ARM64).
- Storage type and capacity.
- Exact OpenPnP release or commit.
- Motion controller connection (USB serial, network, or other).
- Camera model(s), and whether a touchscreen is required.
- Whether maintenance access is local, SSH, or both.

## Licensing

OpenPnP and every bundled dependency retain their own licenses and notices. Before distributing a Neway image, record the exact versions, license texts, source-offer obligations where applicable, and any required attribution. See `LICENSES.md` once added.
