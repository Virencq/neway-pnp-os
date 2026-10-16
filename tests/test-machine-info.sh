#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
script="$root/config/includes.chroot/usr/local/sbin/neway-machine-info"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Run in a private fixture by substituting the fixed paths in a temporary copy.
sed \
  -e "s|/etc/neway/machine-serial|$tmp/machine-serial|g" \
  -e "s|/etc/machine-id|$tmp/machine-id|g" \
  -e "s|/var/lib/neway/identity|$tmp/identity|g" \
  -e "s|/dev/tpmrm0|$tmp/tpmrm0|g" \
  -e "s|/dev/tpm0|$tmp/tpm0|g" \
  "$script" > "$tmp/neway-machine-info"
chmod 0755 "$tmp/neway-machine-info"
printf '%s\n' 'NEWAY-PNP-2026-000001' > "$tmp/machine-serial"
printf '%s\n' 'test-machine-id' > "$tmp/machine-id"
mkdir -p "$tmp/identity"
printf '%s\n' verified > "$tmp/identity/controller-attestation.verified"

# TPM nodes are character-device checks in production. Use a wrapper to test the
# missing-TPM branch deterministically without requiring host hardware.
if "$tmp/neway-machine-info" >"$tmp/out" 2>&1; then
  echo "Expected missing TPM to block readiness" >&2
  exit 1
fi
grep -q 'Serial format valid: yes' "$tmp/out"
grep -q 'TPM device node: not-detected' "$tmp/out"
grep -q 'Remote maintenance readiness: blocked' "$tmp/out"

printf '%s\n' 'machine-info tests passed'
