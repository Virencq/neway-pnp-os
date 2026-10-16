# Neway PnP OS

Minimal Debian Trixie amd64 live ISO prototype for Neway pick-and-place machines. OpenPnP is included and auto-launched. ISO size is accepted as-is; no hard size ceiling is enforced.

## Build design

- Debian Live `live-build`, `--variant=minbase`, APT recommends and indices disabled.
- Minimal Xorg/Openbox session; no full desktop environment.
- The CI workflow builds the Neway-customized OpenPnP source and copies the runtime JAR and dependency libraries into the image.
- An unprivileged `neway` user autologs in on tty1. Openbox launches OpenPnP automatically.
- CI validates shell configuration and the ISO checksum before uploading the artifact.

## Machine identity and remote maintenance

This feature branch adds:
- NetworkManager DHCP/autoconnect for common USB phone tether drivers, with tether routes preferred over ordinary Ethernet routes.
- TPM 2.0 diagnostic tooling and Neway serial identity checks.
- WireGuard package/configuration scaffolding for private technician access.
- SSH key-only policy, a fail-closed provisioning gate, and nftables blocking TCP/22 except through `wg0`.
- A signed Neway update-approval preflight that checks machine binding, expiry, artifact SHA-256, and a controller safe-state marker.
- Factory provisioning and security acceptance documentation.

**Not production-ready yet:** TPM attestation enrollment, the STM32 secure-element challenge-response verifier, Neway's device registry and key-revocation service, the controller safe-state service, and the actual signed update installer are not implemented in this branch. Remote SSH remains disabled until required provisioning artifacts are present. No private keys or production credentials are shipped.

## Important validation status

A successful build does not prove that the image boots or that camera, USB tethering, TPM, secure element, or motion-controller hardware works. This is a live ISO prototype; machine identity and settings will not persist across reboot unless the OS is installed to persistent storage or a properly configured persistence layer is added.

Before production use, test UEFI/Secure Boot, display, camera capture, USB/serial connection, machine configuration storage, recovery, USB tether reconnect, VPN isolation, SSH restrictions, identity cloning/revocation, and update rejection during an active job on the actual Neway PC.

## Official references

- [Debian Live Manual](https://live-team.pages.debian.net/live-manual/html/live-manual.en.html)
- [Debian Trixie NetworkManager](https://packages.debian.org/trixie/net/network-manager)
- [Debian Trixie NetworkManager connection profile properties](https://manpages.debian.org/trixie/network-manager/nm-settings-nmcli.5.en.html)
- [Debian Trixie WireGuard tools](https://packages.debian.org/trixie/net/wireguard-tools)
- [Debian Trixie TPM tools](https://packages.debian.org/trixie/amd64/tpm2-tools)
- [Debian Trixie systemd TPM enrollment](https://manpages.debian.org/trixie/systemd-cryptsetup/systemd-cryptenroll.1.en.html)
- [The Update Framework specification](https://theupdateframework.github.io/specification/v1.0.20/)
- [WireGuard quick start](https://www.wireguard.com/quickstart/)
- [OpenPnP developer guide](https://github.com/openpnp/openpnp/wiki/Developers-Guide)

OpenPnP is GPL-3.0 licensed; see [LICENSES.md](LICENSES.md) for project licensing notes.
