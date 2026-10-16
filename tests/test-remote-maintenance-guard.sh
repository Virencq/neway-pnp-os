#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
guard="$root/config/includes.chroot/usr/local/sbin/neway-remote-maintenance-guard"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Substitute all host paths so the test is deterministic on provisioned and unprovisioned hosts.
sed \
  -e "s|/etc/neway/machine-serial|$tmp/machine-serial|g" \
  -e "s|/etc/wireguard/wg0.conf|$tmp/wg0.conf|g" \
  -e "s|/var/lib/neway/identity/controller-attestation.verified|$tmp/controller-attestation.verified|g" \
  -e "s|/etc/neway/maintenance-enabled|$tmp/maintenance-enabled|g" \
  -e "s|/dev/tpmrm0|$tmp/tpmrm0|g" \
  -e "s|/dev/tpm0|$tmp/tpm0|g" \
  "$guard" > "$tmp/guard"
chmod 0755 "$tmp/guard"

if "$tmp/guard" --unknown >/dev/null 2>&1; then
  echo "Expected unknown mode to be rejected" >&2
  exit 1
fi
if "$tmp/guard" --preflight >/dev/null 2>&1; then
  echo "Expected missing serial to block preflight" >&2
  exit 1
fi
printf '%s\n' 'remote-maintenance guard tests passed'
