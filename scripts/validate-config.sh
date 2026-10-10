#!/usr/bin/env bash
set -Eeuo pipefail
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

required=(
  config/package-lists/neway.list.chroot
  config/includes.chroot/etc/skel/.bash_profile
  config/includes.chroot/etc/skel/.xinitrc
  config/includes.chroot/etc/xdg/openbox/autostart
  config/includes.chroot/usr/local/bin/neway-openpnp
  config/hooks/live/9998-neway-operator.hook.chroot
  scripts/build-iso.sh
)
for path in "${required[@]}"; do
  [[ -s "$path" ]] || { printf 'Missing required file: %s\n' "$path" >&2; exit 1; }
done

grep -Fxq 'openjdk-21-jre' config/package-lists/neway.list.chroot
grep -Fxq 'xinit' config/package-lists/neway.list.chroot
grep -Fxq 'openbox' config/package-lists/neway.list.chroot
grep -Fxq 'user-setup' config/package-lists/neway.list.chroot
if grep -Eq '^(maven|openjdk-21-jdk|git)$' config/package-lists/neway.list.chroot; then
  echo 'Build-only packages must not be installed in the final image.' >&2
  exit 1
fi
grep -q 'exec /usr/bin/java' config/includes.chroot/usr/local/bin/neway-openpnp
grep -q 'neway-openpnp' config/includes.chroot/etc/xdg/openbox/autostart
grep -q '400' scripts/build-iso.sh
printf '%s\n' 'Minimal OpenPnP ISO configuration validation passed.'
