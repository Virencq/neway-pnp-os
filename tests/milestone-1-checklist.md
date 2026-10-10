# Milestone 1 — Base OS prototype validation checklist

This checklist validates the OS image only. Passing VM checks does not prove Neway hardware compatibility or OpenPnP readiness.

## Source/configuration checks

- [ ] Build configuration targets x86-64 / Debian `amd64`.
- [ ] The base image build does not fetch, compile, or install OpenPnP.
- [ ] The `neway` account exists and is not root.
- [ ] ISO SHA-256 manifest is generated and validates.
- [ ] The build uses Debian Trixie's `live-build` package without patching installed helper scripts.

## VM smoke test

- [ ] ISO boots using UEFI.
- [ ] tty1 autologin works for the `neway` operator.
- [ ] Xorg starts and an Openbox session is visible.
- [ ] No full GNOME/KDE desktop is installed.
- [ ] USB and serial devices enumerate and required group membership is present.
- [ ] Maintenance/recovery access works if the graphical session fails.
- [ ] Live-session persistence behavior is documented and tested; do not assume changes survive reboot.

## Hardware test (required before production)

- [ ] Cold boot and repeated reboot on target mini PC.
- [ ] USB motion controller enumerates reliably after boot and reconnect.
- [ ] Correct serial permissions work as the non-root operator.
- [ ] Each production camera enumerates.
- [ ] GPU/display output, touchscreen and resolution work if fitted.
- [ ] Configuration survives reboot using the intended persistent installation.
- [ ] Hardware remains stable through an extended run.

## Later OpenPnP milestone

- [ ] Install OpenPnP from a verified release or pinned customized source commit.
- [ ] Confirm Java runtime and native dependencies.
- [ ] Confirm cameras, OpenCV vision functions, controller connectivity, machine configuration and calibration.
- [ ] Verify logs, update/rollback and recovery behavior.
- [ ] Review applicable licenses and source-distribution obligations.

Record machine model, BIOS/UEFI version, CPU, RAM, GPU, storage, controller firmware, camera model, image version, and test logs for every hardware test.
