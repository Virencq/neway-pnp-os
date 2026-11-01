#!/usr/bin/env bash
set -Eeuo pipefail

[[ "$(id -u)" -eq 0 ]] || { echo "Run inside the Debian Trixie build container as root." >&2; exit 1; }
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# Neway-supplied, prebuilt application committed to this branch.
source_jar="$repo_root/openpnp-gui-0.0.1-alpha-SNAPSHOT.jar"
[[ -s "$source_jar" ]] || {
  echo "Missing custom OpenPnP JAR: $source_jar" >&2
  exit 1
}
command -v unzip >/dev/null || { echo "unzip is required to validate the custom JAR." >&2; exit 1; }
unzip -tq "$source_jar" >/dev/null
manifest="$(unzip -p "$source_jar" META-INF/MANIFEST.MF)"
printf '%s\n' "$manifest" | grep -Eiq '^Main-Class:[[:space:]]*[^[:space:]]+' || {
  echo "Custom JAR manifest has no Main-Class; cannot launch with java -jar." >&2
  exit 1
}

build_dir="$repo_root/.build/live-build"
output_dir="$repo_root/build-output"
[[ ! -L "$build_dir" ]] || { echo "Refusing to remove symlink: $build_dir" >&2; exit 1; }
rm -rf -- "$build_dir"
mkdir -p "$build_dir/config" "$output_dir"
rm -f "$output_dir/neway-pnp-os-amd64.iso" "$output_dir/SHA256SUMS"
cp -a "$repo_root/config/." "$build_dir/config/"
install -d "$build_dir/config/includes.chroot/opt/openpnp"
install -m 0644 "$source_jar" "$build_dir/config/includes.chroot/opt/openpnp/openpnp-gui.jar"
(
  cd "$build_dir/config/includes.chroot/opt/openpnp"
  sha256sum openpnp-gui.jar > openpnp-gui.jar.sha256
)
printf 'Neway custom OpenPnP artifact: %s\n' "$(sha256sum "$source_jar" | cut -d ' ' -f1)" \
  > "$build_dir/config/includes.chroot/opt/openpnp/BUILD-INFO.txt"
find "$build_dir/config/hooks/live" -type f -name '*.hook.chroot' -exec chmod 0755 {} +
chmod 0755 "$build_dir/config/includes.chroot/usr/local/bin/neway-openpnp"
chmod 0755 "$build_dir/config/includes.chroot/etc/skel/.xinitrc"

cd "$build_dir"
lb config noauto \
  --mode debian \
  --distribution trixie \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --archive-areas "main contrib non-free-firmware" \
  --debian-installer none \
  --apt-recommends false \
  --apt-indices false \
  --debootstrap-options "--variant=minbase" \
  --firmware-chroot false \
  --memtest none \
  --security true \
  --bootappend-live "boot=live components quiet"

lb build
iso="$(find "$build_dir" -maxdepth 1 -type f -name '*.iso' -print -quit)"
[[ -n "$iso" && -s "$iso" ]] || { echo "live-build did not produce an ISO." >&2; exit 1; }

size_bytes="$(stat -c '%s' "$iso")"
install -m 0644 "$iso" "$output_dir/neway-pnp-os-amd64.iso"
(
  cd "$output_dir"
  sha256sum neway-pnp-os-amd64.iso > SHA256SUMS
)
printf 'ISO bytes: %s\n' "$size_bytes"
printf 'ISO MiB: %.2f\n' "$(awk -v n="$size_bytes" 'BEGIN { print n / 1048576 }')"
printf 'SHA-256: %s\n' "$(sha256sum "$output_dir/neway-pnp-os-amd64.iso" | cut -d ' ' -f1)"
