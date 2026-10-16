#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
guard="$root/config/includes.chroot/usr/local/sbin/neway-remote-maintenance-guard"

bash -n "$guard"
if "$guard" --unknown >/dev/null 2>&1; then
  echo "Expected unknown mode to be rejected" >&2
  exit 1
fi
if "$guard" --preflight >/dev/null 2>&1; then
  echo "Expected unprovisioned build host to fail preflight" >&2
  exit 1
fi
printf '%s\n' 'remote-maintenance guard tests passed'
