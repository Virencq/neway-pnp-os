#!/usr/bin/env bash
set -Eeuo pipefail

# Run as root inside a Debian Trixie build environment.
if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: run this script as root (for example: sudo bash scripts/build-iso.sh)." >&2
  exit 1
fi

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

build_dir="$repo_root/.build/live-build"
output_dir="$repo_root/build-output"

if [[ -L "$build_dir" ]]; then
  echo "ERROR: refusing to remove symlink build directory: $build_dir" >&2
  exit 1
fi

rm -rf -- "$build_dir"
mkdir -p "$build_dir/config" "$output_dir"
rm -f -- "$output_dir/neway-pnp-os-amd64.iso" "$output_dir/SHA256SUMS"
cp -a "$repo_root/config/." "$build_dir/config/"

cd "$build_dir"
lb config noauto \
  --mode debian \
  --distribution trixie \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --archive-areas "main contrib non-free-firmware" \
  --debian-installer none \
  --security true \
  --bootappend-live "boot=live components quiet"

# Use the unmodified Debian Trixie live-build package; do not patch system helpers.
lb build

iso="$(find "$build_dir" -maxdepth 1 -type f -name '*.iso' -print -quit)"
if [[ -z "$iso" || ! -s "$iso" ]]; then
  echo "ERROR: live-build completed without producing an ISO." >&2
  exit 1
fi

install -m 0644 "$iso" "$output_dir/neway-pnp-os-amd64.iso"
(
  cd "$output_dir"
  sha256sum neway-pnp-os-amd64.iso > SHA256SUMS
)
printf 'Built ISO: %s\n' "$output_dir/neway-pnp-os-amd64.iso"
printf 'Checksum: %s\n' "$output_dir/SHA256SUMS"
