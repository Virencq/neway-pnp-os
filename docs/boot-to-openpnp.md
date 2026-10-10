# Boot-to-OpenPnP prototype

## Current design

- Target: Debian Trixie amd64 live ISO for Intel/AMD x86-64 PCs.
- Application: upstream OpenPnP 2.6 source pinned to commit `5bd404cfc70f34103a3ca0fbb6b50c2b465f407c`.
- Build: OpenPnP is compiled during the live-build chroot stage; the hook verifies the exact Git commit before compilation.
- Runtime: dedicated unprivileged `neway` account, tty1 autologin, Xorg + Openbox, then OpenPnP. There is no GNOME/KDE desktop.
- Recovery: OpenPnP output is appended to `/home/neway/.local/state/neway/openpnp.log`. The launcher permits at most three starts in a rolling ten-minute window before showing a recovery dialog.
- Machine data: OpenPnP's normal per-user configuration is kept under `/home/neway/.openpnp`.

## Build requirements and limitations

The image build needs network access to GitHub and Maven repositories. The build uses a pinned OpenPnP source commit but Maven dependency repositories are not yet snapshot-locked; this is not yet a bit-for-bit reproducible build. The OpenPnP upstream source is licensed under GPL-3.0; see upstream licensing and retain its notices when redistributing.

This is a live ISO prototype, not an installer. Live-session changes—including machine configuration—are normally lost on reboot unless a supported persistence device/partition is configured. Do not use it for production machine motion until persistence, UEFI VM boot, camera/serial checks, and Neway controller validation have passed.

## First validation

1. Run the GitHub Actions workflow and inspect the complete log; the OpenPnP build hook must complete.
2. Download the ISO artifact and verify its SHA-256 manifest.
3. Boot in a UEFI VM. Confirm it reaches OpenPnP without manual login and that no desktop shell is presented.
4. Confirm the OpenPnP log is created and simulate a launch failure to validate the bounded restart behavior.
5. Validate configuration retention and recovery separately; a successful live ISO build alone does not prove either.
