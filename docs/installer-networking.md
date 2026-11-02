# Installer and networking implementation

## Current implementation

The live-build configuration targets Debian 13 (Trixie), amd64, and requests
the Debian Installer live integration:

- `--debian-installer live` builds the live installer path.
- `--debian-installer-gui true` requests the graphical installer.
- `debian-installer-launcher` provides the desktop launcher in the live session.
- NetworkManager and wpa_supplicant provide managed Ethernet/Wi-Fi networking.
- `iw` and `rfkill` provide wireless diagnostics and radio control.
- Firmware packages cover common Intel, Realtek, Atheros, Broadcom and MediaTek
  devices. Actual device support still depends on the exact chipset and kernel.

The live-installer component is a Debian Installer udeb used by the installer
build; it must not be added as if it were an ordinary package in the live
filesystem package list.

## Validate the image

After building, test in VirtualBox with a blank virtual disk and network adapter:

1. Boot the ISO in live mode.
2. Confirm `NetworkManager.service` is active:
   `systemctl is-active NetworkManager`.
3. Confirm an Ethernet interface receives DHCP and DNS works.
4. Confirm the installer launcher is present and starts Debian Installer.
5. Install to the disposable virtual disk, reboot without the ISO, and verify
   the installed system boots.
6. Verify networking again in the installed system.
7. Confirm the operator's OpenPnP data is preserved across reboot.

VM Ethernet testing does not establish physical Wi-Fi compatibility. Test the
actual Wi-Fi chipset on each target hardware family.

## Important outstanding inputs

This repository currently does not contain the OpenPnP JAR, a pinned upstream
OpenPnP release, or its SHA-256. Therefore this change does not claim to fix or
package automatic OpenPnP startup. Add the approved artifact and its verified
checksum before enabling an OpenPnP systemd service or publishing a production
image.

Likewise, do not embed a universal operator password, WireGuard private key,
RustDesk permanent password, or shared device credential in the ISO. Remote
assistance requires per-device identity/provisioning and a reviewed trust model;
it is not enabled by this change.

## Official references

- Debian Live Manual: https://live-team.pages.debian.net/live-manual/
- Debian Live Manual, installer customization:
  https://live-team.pages.debian.net/live-manual/html/live-manual/customizing-installer.en.html
- Debian live-build package: https://packages.debian.org/trixie/live-build
- NetworkManager: https://networkmanager.dev/docs/
