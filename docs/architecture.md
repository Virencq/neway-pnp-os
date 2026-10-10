# Neway PnP OS architecture

## Goal

Build a single-purpose machine appliance. Power-on should lead to OpenPnP, not a desktop session or shell prompt.

## Base-image direction

Use a minimal Debian Trixie root filesystem with a read-only SquashFS system and a controlled writable overlay/data partition. The upstream reference implementation is [carstenandrich/debian-minimal-live](https://github.com/carstenandrich/debian-minimal-live). Reuse its design principles, not its entire default package set or its UEFI-only assumptions without validation.

The current target is UEFI x86-64. Legacy BIOS support is not a requirement unless Neway hardware testing establishes otherwise.

## Runtime layers

1. Linux kernel, initramfs, systemd, udev and essential base utilities.
2. Minimal graphics: X server and only the graphics/input drivers needed on the target PC.
3. OpenPnP's official Linux test .deb, installed by APT to resolve declared runtime dependencies.
4. OpenPnP launcher managed by systemd or a minimal graphical session, running as unprivileged user neway.
5. Writable persistent data for OpenPnP settings, calibration, jobs and logs.

Do not add a display manager, full desktop environment, editor, office suite, browser, media player, Maven, compiler, Git, or other development tools to the target image unless a documented runtime requirement proves otherwise.

## Dependency policy

- Inspect the .deb control metadata and dependency declarations for each build.
- Record OpenPnP package version, package architecture, download URL and SHA-256.
- Let APT resolve declared dependencies; do not guess Java/native dependencies from old instructions.
- Check actual runtime shared-library dependencies and startup logs.
- Test USB/serial controller access and camera capture on real hardware before removing additional libraries or rules.
- Do not assume that OpenPnP's bundled Java runtime is present until verified in the downloaded package.

## Read-only and persistence model

The base operating system should be replaceable without losing machine data. OpenPnP configuration, calibration, job files and logs must be stored in a persistent writable location, not only in a volatile overlay. Document backup and recovery before production deployment.

## Security and recovery

- Run OpenPnP as neway, never as root.
- Grant serial, USB and camera access narrowly based on actual device requirements.
- Keep a documented maintenance/recovery path; the normal operator flow remains OpenPnP-only.
- Do not enable remote login by default unless a support workflow requires it.

## Validation gates

1. Build succeeds reproducibly and records input hashes.
2. Image boots under UEFI in a VM.
3. OpenPnP starts without interactive login.
4. Keyboard, mouse/touch input and application dialogs work.
5. OpenPnP configuration persists across reboot.
6. Actual Neway controller connects and remains stable.
7. Actual cameras capture and vision processing works.
8. Power-cycle, application restart and recovery are tested.

Passing the image build alone does not imply any later gate has passed.
