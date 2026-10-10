#!/usr/bin/env bash
set -Eeuo pipefail

# Run as root: live-build uses debootstrap, chroot and mount operations.
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

if [[ -d "$build_dir/config/hooks/live" ]]; then
  find "$build_dir/config/hooks/live" -type f -name '*.hook.chroot' -exec chmod 0755 {} +
fi

# Patch the known live-build Contents index URL bug in the runner's installed
# helper: Debian stores Contents-amd64.gz under the component path (main/).
# Fail explicitly if the expected upstream code changes instead of silently
# building with an unpatched helper.
helper="/usr/lib/live/build/lb_chroot_linux-image"
if [[ ! -f "$helper" ]]; then
  echo "ERROR: expected live-build helper not found: $helper" >&2
  exit 1
fi
if grep -Fq '/dists/${LB_PARENT_DISTRIBUTION}/Contents-${LB_ARCHITECTURES}.gz' "$helper"; then
  sed -i 's|/dists/${LB_PARENT_DISTRIBUTION}/Contents-${LB_ARCHITECTURES}.gz|/dists/${LB_PARENT_DISTRIBUTION}/main/Contents-${LB_ARCHITECTURES}.gz|g' "$helper"
fi
if grep -Fq '/dists/${LB_DISTRIBUTION}/Contents-${LB_ARCHITECTURES}.gz' "$helper"; then
  sed -i 's|/dists/${LB_DISTRIBUTION}/Contents-${LB_ARCHITECTURES}.gz|/dists/${LB_DISTRIBUTION}/main/Contents-${LB_ARCHITECTURES}.gz|g' "$helper"
fi
if grep -Eq '/dists/\$\{LB_(PARENT_)?DISTRIBUTION\}/Contents-\$\{LB_ARCHITECTURES\}\.gz' "$helper"; then
  echo "ERROR: live-build Contents URL patch did not apply." >&2
  exit 1
fi

cd "$build_dir"
lb config noauto \
  --mode debian \
  --distribution trixie \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --archive-areas "main contrib non-free-firmware" \
  --debian-installer none \
  --security false \
  --bootappend-live "boot=live components quiet"

# Trixie's security archive is configured explicitly in config/archives.
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
