# Build workflow: Codespaces and GitHub Actions

## Intended split

- **Codespaces:** edit configuration, run syntax checks, review logs, and prepare commits.
- **GitHub Actions:** build the base Debian Live ISO inside a Debian Trixie container.
- **VM / hardware:** boot the downloaded ISO in a UEFI virtual machine first; then test the actual Neway controller and cameras on the target PC.

Debian Live builds use debootstrap and chroot/mount operations. The workflow runs the build in a privileged Debian Trixie container so the live-build toolchain matches the target distribution instead of patching Ubuntu's installed helper scripts.

## Run the workflow

1. Open the pull request or repository's Actions tab.
2. Select **Build Neway PnP OS ISO** and run it manually if workflow dispatch is available; relevant pull-request updates also trigger it.
3. Wait for all validation, ISO generation, and checksum steps to succeed.
4. Download the `neway-pnp-os-amd64-<commit>` artifact. It contains the ISO and `SHA256SUMS`.
5. Verify locally with `sha256sum -c SHA256SUMS` from the directory containing both files.
6. Boot the ISO in a UEFI VM and complete `tests/milestone-1-checklist.md`.

## Current implementation and limitations

The current milestone builds a minimal Debian Trixie amd64 base OS with Xorg, Openbox, a non-root `neway` operator, and tty1 autologin. OpenPnP is **not installed**; it will be handled by a separate later installer/package.

This is a live ISO prototype, not a production image or SSD installer. Configuration changes normally disappear when the live session reboots unless persistence is configured. A successful ISO build proves only that image generation succeeded; it does not prove UEFI boot or Neway hardware compatibility.
