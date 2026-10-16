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
10. Run `neway-machine-info`, `neway-remote-maintenance-guard --preflight`, then
    `neway-enable-remote-maintenance`.
11. Verify that TCP/22 is unreachable on Ethernet/Wi-Fi/USB-tether interfaces and reachable
    only through the authorized WireGuard peer.
12. Disconnect/reconnect the phone, reboot twice, and confirm serial, VPN identity and
    revocation state remain correct.

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
- An update request during an active job must be rejected. A signed but unapproved release
  must be rejected. A wrong digest, expired approval, or unauthorized downgrade must fail.
- An interrupted update must recover without enabling motion or bypassing the emergency stop.

## Current not-yet-implemented gates

The TPM enrollment/attestation client, controller secure-element challenge-response
verifier, central registry, VPN key issuance/revocation, signed update client, and controller
safe-state API are external implementation milestones. The current local shell gate does
not replace those components.
