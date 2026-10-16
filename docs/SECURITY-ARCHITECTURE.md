# Neway PnP OS machine identity and remote maintenance

## Current implementation scope

This branch adds Debian package/configuration scaffolding and fail-closed local checks.
It does **not** enroll production identities, issue certificates, provision VPN keys,
implement STM32 secure-element challenge-response, or install updates. Do not describe
the feature as production-ready until those external services and hardware tests exist.

## Identity model

- Neway serial: manufacturer-assigned, for example `NEWAY-PNP-2026-000001`.
  Store it in `/etc/neway/machine-serial`, root-owned and not writable by the
  `neway` operator. Do not generate a serial from a MAC address.
- OS machine-id: unique to an installed OS, useful for local diagnostics only; it is
  not a cryptographic identity and must not be used alone to authorize a machine.
- TPM 2.0: use a TPM-resident attestation key generated during controlled factory
  provisioning. Keep private key material non-exportable where the TPM supports it.
  Register its public identity and attestation evidence with Neway's device registry.
- STM32 controller secure element: the controller firmware must implement a documented
  nonce-based challenge-response, with the private key generated/stored in the secure
  element and the verifier pinned to Neway's controller trust root. The STM32H723 UID
  alone is an identifier, not a secret or proof of authenticity.
- Server registry: bind Neway serial, TPM public identity, controller attestation identity,
  hardware revision, OS release, controller firmware release, and revocation status.

The marker `/var/lib/neway/identity/controller-attestation.verified` is a local gate
contract only. A trusted verifier must create it only after checking a fresh signed
challenge-response against the pinned controller trust root. This repository does not
yet implement that verifier; creating the marker manually is not secure enrollment.

## USB tethering

NetworkManager is installed and an Ethernet DHCP/autoconnect profile is shipped for
both physical Ethernet and phone tethering interfaces exposed by Linux as Ethernet
(RNDIS/CDC-ECM). Connect the Android phone by USB and enable USB tethering on the phone.
The Linux PC is the USB host; Linux USB gadget mode is not needed for this topology.

Phone vendors, Android versions, and kernels expose different USB network drivers. Test
the actual target phones. Keep local Ethernet available for machine operation; do not
bridge customer LAN traffic into the technician VPN. The USB connection is a transport,
not an authentication method.

## Technician access

- WireGuard is the only intended technician network path.
- No WireGuard configuration, keys, or technician authorized_keys are included in the image.
- SSH is gated by provisioning marker files and a pre-start validation service. Password
  authentication and root login are disabled; only members of `neway-maintenance` with
  public keys can log in.
- nftables drops inbound TCP/22 unless the interface is `wg0`.
- Provision a unique WireGuard peer per machine. Use narrow AllowedIPs, firewall the
  server side, rotate/revoke peer keys, and keep audit logs.
- Never expose SSH directly to the public Internet or use the phone's public IP as an
  access-control boundary.

## Updates and safe machine state

Policy: Neway approval plus an explicit safe maintenance window. No automatic OpenPnP,
OS, or controller firmware installation is enabled by this branch.

Before an updater is implemented, it must:
1. Verify signed release metadata and artifact digests against a pinned public trust root.
2. Reject rollback/downgrade unless a separately signed recovery authorization permits it.
3. Require a Neway approval record tied to the exact machine, release digest, and expiry.
4. Require the machine controller to report motion stopped, no active job, outputs safe,
   and a locally enforceable maintenance window. A remote request alone must not create
   the safe-state signal.
5. Stage the update, verify before activation, record actor/version/result, and provide a
   tested recovery path.
6. Keep the emergency stop and motion safety interlocks independent of the OS, VPN,
   OpenPnP, and update service.

Use TUF or an equivalent reviewed update framework rather than inventing a custom
signature/rollback protocol. Keep root signing keys offline and outside this repository.
Debian security updates must also follow Neway's approval and machine-safe policy; do not
enable generic unattended package upgrades that can restart the machine during production.

## Tamper resistance

Use UEFI Secure Boot where the target firmware supports a Neway-controlled trust chain,
restrict external boot in manufacturing, set a firmware admin password, protect the
chassis with a tamper-evident seal/switch, and log deviations. TPM measured boot is useful
only when the verifier checks measurements against an expected policy. Disk encryption
is a separate decision: TPM auto-unlock alone may not protect data from a person who can
boot the authorized machine; keep a recovery method under Neway control.

## Provisioning order

1. Install to persistent SSD/NVMe; a live ISO without persistence cannot be the final
   machine-identity store.
2. Assign and record the Neway serial.
3. Enroll TPM identity and register its public identity with Neway.
4. Enroll the STM32 secure element and validate challenge-response using a fresh nonce.
5. Register the device and its revocation state in the Neway registry.
6. Provision unique WireGuard peer settings and technician SSH public keys.
7. Verify all checks, then run `neway-enable-remote-maintenance` as root.
8. Test revocation, offline behavior, boot recovery, tether reconnect, and fail-closed SSH.

## Official references

- Debian Trixie NetworkManager package: https://packages.debian.org/trixie/net/network-manager
- Debian Trixie NetworkManager CLI manual: https://manpages.debian.org/trixie/network-manager/nmcli.1.en.html
- Debian Trixie WireGuard tools: https://packages.debian.org/trixie/net/wireguard-tools
- Debian Trixie TPM tools: https://packages.debian.org/trixie/amd64/tpm2-tools
- Debian Trixie systemd TPM enrollment: https://manpages.debian.org/trixie/systemd-cryptsetup/systemd-cryptenroll.1.en.html
- Debian Trixie unattended-upgrades: https://manpages.debian.org/trixie/unattended-upgrades/unattended-upgrade.8.en.html
- TUF specification: https://theupdateframework.github.io/specification/v1.0.20/
- WireGuard quick start: https://www.wireguard.com/quickstart/
