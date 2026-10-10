# Milestone 1 — Prototype validation checklist

This checklist is for a prototype only. Passing VM checks does not prove Neway hardware compatibility.

## Source/configuration checks

- [ ] Build configuration targets x86-64 / Debian `amd64`.
- [ ] The build hook fetches the pinned OpenPnP source commit `5bd404cfc70f34103a3ca0fbb6b50c2b465f407c` and rejects a commit mismatch.
- [ ] Maven build completes and the expected OpenPnP JAR plus dependency directory are present.
- [ ] No credentials, calibration files, or local machine secrets are embedded.
- [ ] ISO SHA-256 manifest is generated and validates.
- [ ] OpenPnP and Debian package licenses/notices are reviewed before redistribution.

## VM smoke test

- [ ] ISO boots using UEFI.
- [ ] OpenPnP launches automatically without manual login.
- [ ] No full desktop environment is shown.
- [ ] OpenPnP window is visible at the configured display resolution.
- [ ] Startup failure is recorded to a readable log.
- [ ] Application restart behavior is bounded and does not create a rapid crash loop.
- [ ] Maintenance/recovery instructions work.
- [ ] Machine configuration persistence behavior is tested; do not assume a live ISO preserves changes after reboot.

## Hardware test (required before production)

- [ ] Cold boot and repeated reboot on target mini PC.
- [ ] USB motion controller enumerates reliably after boot and reconnect.
- [ ] Correct serial permissions work as the non-root operator.
- [ ] Each production camera opens and streams.
- [ ] OpenCV vision functions used by Neway work.
- [ ] GPU/display output, touchscreen and resolution work if fitted.
- [ ] Configuration and calibration survive reboot and the documented update procedure.
- [ ] Motion and camera operation remain stable through an extended run.

Record machine model, BIOS/UEFI version, CPU, RAM, GPU, storage, controller firmware, camera model, image version, and test logs for every hardware test.
