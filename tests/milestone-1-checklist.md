# Minimal OpenPnP appliance — validation checklist

This checklist distinguishes a successful image build from actual runtime and hardware validation.

## Package audit

- [ ] Download the latest official Linux test .deb from the OpenPnP test-download page.
- [ ] Record download URL, SHA-256, Package, Version, Architecture, Depends and Pre-Depends.
- [ ] Verify whether the .deb bundles a Java runtime; do not assume it does.
- [ ] Inspect native shared-library dependencies before finalizing the rootfs package set.
- [ ] Ensure build-only tools are not installed in the target root filesystem.

## Image/VM smoke test

- [ ] Build the minimal x86-64 UEFI image and record the rootfs and final image sizes.
- [ ] Boot in a UEFI VM.
- [ ] OpenPnP starts automatically as the unprivileged neway user.
- [ ] No desktop environment, editor, browser, office suite, or media player is present.
- [ ] Keyboard, mouse and application dialogs work.
- [ ] Startup failure is logged and restart behavior avoids a rapid crash loop.
- [ ] OpenPnP configuration persists across reboot.
- [ ] Recovery/maintenance path is documented and tested.

## Neway hardware validation — required before production

- [ ] Cold boot and repeated reboot on target PC.
- [ ] USB motion controller enumerates reliably, including after reconnect.
- [ ] Serial device permissions work as the non-root operator.
- [ ] Each production camera opens and streams through the selected OpenPnP Capture/backend path.
- [ ] Required OpenCV vision functions work.
- [ ] GPU/display output, touchscreen and target resolution work if fitted.
- [ ] Configuration, calibration, job files and logs survive reboot and OS update.
- [ ] Controller and cameras remain stable through an extended run.

Record machine model, BIOS/UEFI version, CPU, RAM, GPU, storage, controller firmware, camera model, image version and logs for every hardware test.
