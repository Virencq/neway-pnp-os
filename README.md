# Neway PnP OS

Debian 13 (Trixie), amd64 live appliance image for Neway pick-and-place machines. The Neway custom OpenPnP distribution is included and launched automatically on the live system.

## Build and application source

- Built with Debian Live `live-build`, using a minimal Xorg/Openbox session.
- The build downloads the approved Neway OpenPnP distribution from the pinned GitHub Release ZIP asset. It verifies the exact SHA-256 before extraction.
- The ZIP must contain exactly one `openpnp-gui.jar` and one `lib/` directory containing the runtime dependency JARs. The build validates the manifest entry point, main class, Javassist and OpenCV JARs.
- The application is installed under `/opt/openpnp`; the startup launcher executes `org.openpnp.Main` with the complete library classpath.
- The committed standalone snapshot JAR is retained as a repository artifact, but the ISO pipeline uses the pinned ZIP because it includes the runtime dependency directory.

## Boot and automatic OpenPnP startup

The existing startup chain is preserved:

1. The live operator account is automatically logged in on `tty1`.
2. `~/.bash_profile` starts Xorg through `/usr/local/bin/neway-startx`.
3. `.xinitrc` starts the Openbox session.
4. Openbox autostart launches `/usr/local/bin/neway-openpnp`.
5. OpenPnP configuration is stored under `~/.openpnp2`; application logs are written under `~/.local/state/neway/openpnp.log`.

Right-click the Openbox background to access the Neway menu. It provides OpenPnP, the Debian installer, network settings and a terminal.

The `nivo:1234` account credential in the current image is for bench testing only. Replace it with unique factory provisioning before deploying devices. Do not ship production machines with this shared test password.

## Install to SSD/NVMe

The image includes Debian Installer in **live installer** mode:

- The boot menu contains the Debian Installer live entry.
- From the running Openbox live session, right-click the background and choose **Install Neway PnP OS to SSD**.
- Debian Installer's live-installer component copies the live filesystem to the selected target disk and then configures the installed system.

The installer is destructive to the selected target disk. Confirm the selected disk and back up existing data before proceeding. Installation and bootloader behavior must be tested in VirtualBox and on the actual target hardware before production release.

## Networking

NetworkManager is enabled. The image includes:
- DHCP and NetworkManager connection management.
- Wi-Fi supplicant and diagnostic tools (`wpasupplicant`, `iw`, `rfkill`).
- Common Debian firmware packages for Intel, Realtek, Atheros and Broadcom wireless devices.
- NetworkManager's GTK connection editor, accessible from the Openbox menu.
- Existing wired and USB-tethering profile configuration.

Actual Wi-Fi support depends on the wireless chipset and its firmware. Test the target PC's exact Wi-Fi adapter, scanning, authentication, DHCP, suspend/resume and reconnect behavior. VirtualBox NAT Ethernet does not validate physical Wi-Fi.

## Remote maintenance

The image includes the pinned RustDesk client, WireGuard tools, OpenSSH, nftables and Neway provisioning scripts. Remote access is intentionally gated until a device-specific WireGuard identity, RustDesk server configuration and machine identity provisioning are installed.

No shared Wireguard private keys, SSH host keys or permanent RustDesk access password are shipped. RustDesk client installation alone does not establish an unattended connection: the Neway hbbs/hbbr servers, server public key and per-device provisioning must be configured. RustDesk file transfer is the intended file/drive access path; verify the required permissions and service behavior on the installed system.

The TPM attestation enrollment, controller secure-element challenge-response verifier, central device registry/key revocation service, production safe-state service and signed update installer remain separate implementation milestones. The current update guard is a preflight check, not an updater.

## Persistence and limitations

A live session is not a substitute for installing the OS. Use the Debian live installer to install to SSD/NVMe when persistent machine configuration, calibration data, OpenPnP jobs and logs are required. Verify those directories survive reboot and OS updates after installation.

A successful CI build proves that the ISO was generated and passed the repository's static checks. It does not prove that the image boots, that OpenPnP initializes the camera or motion controller, or that Wi-Fi, RustDesk, WireGuard, TPM and USB hardware work. Those require VirtualBox and physical-machine acceptance tests.

## CI output

The GitHub Actions workflow builds the ISO on Debian Trixie and uploads:
- `neway-pnp-os-amd64.iso`
- `SHA256SUMS`

The artifact is a test build until boot, installation, OpenPnP hardware, networking and remote-maintenance acceptance tests pass.

## Official references

- [Debian Live Manual](https://live-team.pages.debian.net/live-manual/html/live-manual.en.html)
- [Debian Live Manual: installer customization](https://live-team.pages.debian.net/live-manual/html/live-manual/customizing-installer.en.html)
- [Debian Trixie live-build options](https://dyn.manpages.debian.org/trixie/live-build/lb_config.1)
- [Debian Trixie Debian Installer launcher](https://manpages.debian.org/trixie/debian-installer-launcher/debian-installer-launcher.8.en.html)
- [Debian Trixie NetworkManager](https://packages.debian.org/trixie/net/network-manager)
- [NetworkManager documentation](https://networkmanager.dev/docs/)
- [WireGuard quick start](https://www.wireguard.com/quickstart/)
- [RustDesk documentation](https://rustdesk.com/docs/en/)
- [OpenPnP developer guide](https://github.com/openpnp/openpnp/wiki/Developers-Guide)

OpenPnP is GPL-3.0 licensed. See [LICENSES.md](LICENSES.md).
