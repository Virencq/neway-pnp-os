#!/usr/bin/env bash
set -Eeuo pipefail

# Run as root: live-build uses debootstrap, chroot and mount operations.
if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: run this script as root (for example: sudo ./scripts/build-iso.sh)." >&2
  exit 1
fi

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

build_dir="$repo_root/.build/live-build"
output_dir="$repo_root/build-output"
mkdir -p "$build_dir" "$output_dir"

# Do not silently reuse a stale live-build tree from another configuration.
rm -rf "$build_dir"/*
cp -a "$repo_root/config/." "$build_dir/config/"

cd "$build_dir"
lb config noauto \
  --mode debian \
  --distribution trixie \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --archive-areas "main contrib non-free-firmware" \
  --debian-installer none \
  --bootappend-live "boot=live components quiet"

lb build

iso="$(find "$build_dir" -maxdepth 1 -type f -name '*.iso' -print -quit)"
if [[ -z "$iso" || ! -s "$iso" ]]; then
  echo "ERROR: live-build completed without producing an ISO." >&2
  exit 1
fi

install -m 0644 "$iso" "$output_dir/neway-pnp-os-amd64.iso"
printf 'Built ISO: %s\n' "$output_dir/neway-pnp-os-amd64.iso"
