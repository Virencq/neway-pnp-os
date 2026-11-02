#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

command -v lb >/dev/null 2>&1 || {
  echo "ERROR: live-build is not installed. Install it on Debian Trixie." >&2
  exit 1
}

# Never reuse stale generated configuration or silently clean user data.
if [ -e config/chroot ] || [ -e chroot ]; then
  echo "ERROR: Existing live-build state detected. Review it before cleaning." >&2
  echo "Run 'sudo lb clean --purge' manually only if you intend a clean rebuild." >&2
  exit 1
fi

lb config
lb build

mkdir -p dist
find . -maxdepth 1 -type f -name '*.iso' -exec cp -f '{}' dist/neway-pnp-os-amd64.iso \;
test -s dist/neway-pnp-os-amd64.iso
sha256sum dist/neway-pnp-os-amd64.iso > dist/neway-pnp-os-amd64.iso.sha256
printf 'Built: %s\n' "$ROOT/dist/neway-pnp-os-amd64.iso"
