#!/usr/bin/env bash
set -Eeuo pipefail

# Inspect the current official OpenPnP Linux test .deb without installing it.
# This is an audit step for selecting the minimal target runtime dependency set.
url="${OPENPNP_TEST_DEB_URL:-https://s3-us-west-2.amazonaws.com/openpnp/OpenPnP-linux-test.deb}"
out_dir="${1:-build-output/openpnp-package-audit}"
mkdir -p "$out_dir"
package="$out_dir/OpenPnP-linux-test.deb"

command -v curl >/dev/null || { echo 'ERROR: curl is required' >&2; exit 1; }
command -v dpkg-deb >/dev/null || { echo 'ERROR: dpkg-deb is required' >&2; exit 1; }

curl --fail --location --retry 3 --output "$package" "$url"
test -s "$package"

{
  printf 'source_url=%s\n' "$url"
  printf 'sha256='; sha256sum "$package" | awk '{print $1}'
  printf 'file_size_bytes='; stat -c '%s' "$package"
  printf '\n--- package metadata ---\n'
  dpkg-deb --info "$package"
  printf '\n--- control fields ---\n'
  dpkg-deb --field "$package" Package Version Architecture Depends Pre-Depends Recommends Suggests
  printf '\n--- bundled Java/runtime candidates ---\n'
  dpkg-deb --contents "$package" | grep -Ei '(/jre/|/jdk/|/java$|libjvm|OpenPnP.*(jar|sh)$|\.desktop$)' || true
} | tee "$out_dir/package-audit.txt"

# Extract package control data for automated review; do not install it here.
dpkg-deb --field "$package" Package Version Architecture Depends Pre-Depends Recommends Suggests > "$out_dir/control-fields.txt"
echo "Audit written to: $out_dir/package-audit.txt"
echo "Package retained at: $package"
