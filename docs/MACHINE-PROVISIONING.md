# Factory provisioning and acceptance procedure

This checklist is for a persistent installed system, not a shared live ISO.

## Factory provisioning

1. Confirm UEFI Secure Boot status and TPM 2.0 presence on the target industrial PC.
2. Install Neway PnP OS to SSD/NVMe and confirm `/etc/machine-id` is stable across reboot.
3. Assign one unique serial from the Neway registry and write it to
   `/etc/neway/machine-serial` (root:root, mode 0644).
4. Generate the TPM attestation key on-device. Export only its public identity and the
   attestation evidence needed for registration; never export or log its private key.
5. Provision the controller secure-element identity and test nonce-based challenge-response.
   The verifier must reject stale/replayed challenges, invalid signatures, wrong controller
   identity, and revoked credentials.
6. Register serial, TPM identity, controller identity, model/revision, and release versions.
7. Install a unique WireGuard config at `/etc/wireguard/wg0.conf` (root:root, mode 0600).
8. Install the authorized technician public keys in a member account of
   `neway-maintenance`; do not use passwords or root SSH.
9. Only after the secure-element verifier has checked the controller, create
   `/var/lib/neway/identity/controller-attestation.verified` as root:root mode 0600,
   with the exact contents `verified`. This file is a gate contract, not proof by itself.
10. Install the Neway update public keyring at `/etc/neway/update-trust.gpg` as root:root.
    Keep the private approval/signing key offline and outside the device and repository.
11. Run `neway-machine-info`, `neway-remote-maintenance-guard --preflight`, then
    `neway-enable-remote-maintenance`.
12. Verify that TCP/22 is unreachable on Ethernet/Wi-Fi/USB-tether interfaces and reachable
    only through the authorized WireGuard peer.
13. Disconnect/reconnect the phone, reboot twice, and confirm serial, VPN identity and
    revocation state remain correct.

## Update approval preflight

A signed approval manifest is stored at `/var/lib/neway/updates/approved-update.txt`,
with detached signature `approved-update.txt.asc` and artifact `release.tar.zst`.
The signed manifest contains exactly one each of:

```text
machine_serial=NEWAY-PNP-2026-000001
release_version=2026.10.16.1
artifact_sha256=<64 hexadecimal characters>
approved_until_utc=2026-10-17T12:00:00Z
```

These values are examples, not a valid approval. The manifest must be signed by the Neway
approval key represented in the installed public keyring. The controller safety service
must write `/run/neway/controller-safe-for-update` as root:root mode 0600 with contents
`safe` only while its locally verified safe-maintenance conditions hold. The marker must
be refreshed and cleared when conditions change.

Run `neway-update-guard` to verify the signed approval, machine binding, expiry, digest,
and safe-state marker. This is a preflight only: it does not install the artifact, provide
rollback protection by itself, or replace a TUF-based update client.

## Acceptance tests

- Two machines must have different serials, TPM public identities, controller identities,
  and WireGuard public keys.
- Copying the OS disk to another PC must not silently transfer device authorization.
- Missing TPM, missing controller verification, invalid serial, missing VPN config, a
  world/group-readable VPN config, invalid WireGuard config, or missing maintenance marker
  must block SSH.
- Wrong technician keys and revoked VPN peers must fail.
- USB tethering must obtain DHCP and restore the route after cable/phone disconnect.
- Loss of VPN must not stop OpenPnP or compromise local motion safety.
- An update request during an active job must be rejected. A signed approval for another
  serial, expired approval, wrong artifact digest, missing safe-state marker, invalid
  signature, or unauthorized downgrade must fail.
- An interrupted update must recover without enabling motion or bypassing the emergency stop.

## Current not-yet-implemented gates

The TPM enrollment/attestation client, controller secure-element challenge-response
verifier, central registry, VPN key issuance/revocation, production controller safe-state
service, and actual signed update installer are external implementation milestones. The
local shell gates are not substitutes for those components.
