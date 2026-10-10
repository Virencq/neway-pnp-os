#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

required_files=(
  "config/package-lists/neway.list.chroot"
  "config/hooks/live/9999-neway-openpnp.hook.chroot"
  "config/includes.chroot/usr/local/bin/neway-openpnp"
  "config/includes.chroot/usr/local/bin/neway-openpnp-session"
  "config/includes.chroot/etc/skel/.bash_profile"
  "config/includes.chroot/etc/skel/.xinitrc"
  "scripts/build-iso.sh"
)
for path in "${required_files[@]}"; do
  if [[ ! -s "$path" ]]; then
    printf 'ERROR: required file missing or empty: %s\n' "$path" >&2
    exit 1
  fi
done

if grep -RniE 'TODO|REPLACE_ME|CHANGEME' config; then
  printf 'ERROR: unresolved placeholder found in build configuration.\n' >&2
  exit 1
fi

if ! grep -Eq '^openjdk-21-jre$' config/package-lists/neway.list.chroot; then
  printf 'ERROR: expected OpenJDK 21 runtime package is missing.\n' >&2
  exit 1
fi
if ! grep -Eq '^readonly OPENPNP_COMMIT="5bd404cfc70f34103a3ca0fbb6b50c2b465f407c" config/hooks/live/9999-neway-openpnp.hook.chroot; then
  printf 'ERROR: OpenPnP source commit is not pinned to the reviewed release commit.\n' >&2
  exit 1
fi

printf 'Configuration validation passed. ISO build, VM boot, persistence, and hardware compatibility remain separate tests.\n'
 config/hooks/live/9999-neway-openpnp.hook.chroot; then
  printf 'ERROR: OpenPnP source commit is not pinned to the reviewed release commit.\n' >&2
  exit 1
fi

printf 'Configuration validation passed. ISO build, VM boot, persistence, and hardware compatibility remain separate tests.\n'
