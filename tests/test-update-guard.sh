#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
guard="$root/config/includes.chroot/usr/local/sbin/neway-update-guard"

bash -n "$guard"
if "$guard" >/dev/null 2>&1; then
  echo "Expected update guard to reject an unprovisioned host" >&2
  exit 1
fi
printf '%s\n' 'update-guard fail-closed test passed'
