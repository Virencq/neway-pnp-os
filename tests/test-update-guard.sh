#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
guard="$root/config/includes.chroot/usr/local/sbin/neway-update-guard"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

sed \
  -e "s|/etc/neway/machine-serial|$tmp/machine-serial|g" \
  -e "s|/etc/neway/update-trust.gpg|$tmp/update-trust.gpg|g" \
  -e "s|/var/lib/neway/updates|$tmp/updates|g" \
  -e "s|/run/neway/controller-safe-for-update|$tmp/controller-safe-for-update|g" \
  "$guard" > "$tmp/guard"
chmod 0755 "$tmp/guard"

if "$tmp/guard" >/dev/null 2>&1; then
  echo "Expected update guard to reject a missing machine serial" >&2
  exit 1
fi
printf '%s\n' 'update-guard fail-closed test passed'
