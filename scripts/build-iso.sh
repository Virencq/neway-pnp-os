#!/usr/bin/env bash
set -Eeuo pipefail

[[ "$(id -u)" -eq 0 ]] || { echo "Run inside the Debian Trixie build container as root." >&2; exit 1; }
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# Immutable, versioned Neway custom OpenPnP distribution published as a GitHub Release asset.
asset_url="https://github.com/Virencq/neway-pnp-os/releases/download/openpnp.jar/openpnp-gui.zip"
asset_sha256="88dea48de22621455b63c9e16e2ef5ca4ad62bb159f075ae924a79cbcebb40a8"

command -v curl >/dev/null || { echo "curl is required to fetch the OpenPnP release asset." >&2; exit 1; }
command -v unzip >/dev/null || { echo "unzip is required to extract the OpenPnP release asset." >&2; exit 1; }

build_dir="$repo_root/.build/live-build"
output_dir="$repo_root/build-output"
download_dir="$repo_root/.build/downloads"
artifact_zip="$download_dir/openpnp-gui.zip"
staging_dir="$repo_root/.build/openpnp-extracted"

[[ ! -L "$build_dir" && ! -L "$download_dir" && ! -L "$staging_dir" ]] || {
  echo "Refusing to remove a symlink in the build staging paths." >&2
  exit 1
}
rm -rf -- "$download_dir" "$staging_dir"
mkdir -p "$download_dir" "$staging_dir" "$output_dir"

echo "Downloading Neway custom OpenPnP distribution..."
curl --fail --location --retry 3 --retry-delay 2 --output "$artifact_zip" "$asset_url"
printf '%s  %s\n' "$asset_sha256" "$artifact_zip" | sha256sum --check --status || {
  echo "OpenPnP release ZIP SHA-256 mismatch; refusing to build." >&2
  exit 1
}
unzip -tq "$artifact_zip" >/dev/null
unzip -q "$artifact_zip" -d "$staging_dir"

# Accept either archive-root files or one containing directory, but require one JAR and lib/*.jar.
mapfile -t app_jars < <(find "$staging_dir" -type f -name 'openpnp-gui.jar' -print)
mapfile -t lib_dirs < <(find "$staging_dir" -type d -name lib -print)
[[ "${#app_jars[@]}" -eq 1 && "${#lib_dirs[@]}" -eq 1 ]] || {
  echo "Expected exactly one openpnp-gui.jar and one lib directory in the distribution ZIP." >&2
  find "$staging_dir" -maxdepth 4 -print >&2
  exit 1
}
source_jar="${app_jars[0]}"
source_lib="${lib_dirs[0]}"
[[ -s "$source_jar" ]]
[[ -n "$(find "$source_lib" -maxdepth 1 -type f -name '*.jar' -print -quit)" ]] || {
  echo "OpenPnP lib directory is empty." >&2
  exit 1
}
command -v java >/dev/null || { echo "Java is required to validate the application entry point." >&2; exit 1; }
unzip -p "$source_jar" META-INF/MANIFEST.MF | grep -Eiq '^Main-Class:[[:space:]]*org\.openpnp\.Main[[:space:]]*$' || {
  echo "Custom JAR manifest does not declare org.openpnp.Main." >&2
  exit 1
}
# Inspect JAR entries with unzip; the JRE image used by CI does not include the JDK 'jar' tool.
unzip -Z1 "$source_jar" | grep -Fxq 'org/openpnp/Main.class' || {
  echo "Custom JAR does not contain org/openpnp/Main.class." >&2
  exit 1
}
find "$source_lib" -maxdepth 1 -type f -name 'javassist-*.jar' -print -quit | grep -q . || {
  echo "Javassist dependency is missing from the runtime lib directory." >&2
  exit 1
}
find "$source_lib" -maxdepth 1 -type f -name 'opencv-*.jar' -print -quit | grep -q . || {
  echo "OpenCV dependency is missing from the runtime lib directory." >&2
  exit 1
}

[[ ! -L "$build_dir" ]] || { echo "Refusing to remove symlink: $build_dir" >&2; exit 1; }
rm -rf -- "$build_dir"
mkdir -p "$build_dir/config"
rm -f "$output_dir/neway-pnp-os-amd64.iso" "$output_dir/SHA256SUMS"
cp -a "$repo_root/config/." "$build_dir/config/"
install -d "$build_dir/config/includes.chroot/opt/openpnp/lib"
install -m 0644 "$source_jar" "$build_dir/config/includes.chroot/opt/openpnp/openpnp-gui.jar"
find "$source_lib" -maxdepth 1 -type f -name '*.jar' -exec install -m 0644 {} "$build_dir/config/includes.chroot/opt/openpnp/lib/" \;
(
  cd "$build_dir/config/includes.chroot/opt/openpnp"
  sha256sum openpnp-gui.jar lib/*.jar > SHA256SUMS
)
{
  printf 'Release asset: %s\n' "$asset_url"
  printf 'Release ZIP SHA-256: %s\n' "$asset_sha256"
  printf 'Application JAR SHA-256: %s\n' "$(sha256sum "$source_jar" | cut -d ' ' -f1)"
  printf 'Runtime dependency JAR count: %s\n' "$(find "$source_lib" -maxdepth 1 -type f -name '*.jar' | wc -l)"
} > "$build_dir/config/includes.chroot/opt/openpnp/BUILD-INFO.txt"

find "$build_dir/config/hooks/live" -type f -name '*.hook.chroot' -exec chmod 0755 {} +
chmod 0755 "$build_dir/config/includes.chroot/usr/local/bin/neway-openpnp"
chmod 0755 "$build_dir/config/includes.chroot/etc/skel/.xinitrc"

cd "$build_dir"
lb config noauto \
  --mode debian \
  --distribution trixie \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --bootloaders "syslinux grub-efi" \
  --archive-areas "main contrib non-free-firmware" \
  --debian-installer none \
  --apt-recommends false \
  --apt-indices false \
  --debootstrap-options "--variant=minbase" \
  --firmware-chroot false \
  --memtest none \
  --security true \
  --bootappend-live "boot=live components quiet username=nivo live-config.nocomponents=user-setup"

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
