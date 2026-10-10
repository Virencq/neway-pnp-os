#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

required_files=(
  "config/package-lists/neway.list.chroot"
  "config/includes.chroot/etc/skel/.bash_profile"
  "config/includes.chroot/etc/skel/.xinitrc"
  "scripts/build-iso.sh"
)
for path in "${required_files[@]}"; do
  if [[ ! -s "$path" ]]; then
    printf "ERROR: required file missing or empty: %s\n" "$path" >&2
    exit 1
  fi
done

if grep -RniE "TODO|REPLACE_ME|CHANGEME" config; then
  printf "ERROR: unresolved placeholder found in build configuration.\n" >&2
  exit 1
fi

if ! grep -Fxq "openbox" config/package-lists/neway.list.chroot; then
  printf "ERROR: Openbox base session package is missing.\n" >&2
  exit 1
fi
if grep -Eq '^(maven|openjdk-21-jdk|git)$' config/package-lists/neway.list.chroot; then
  printf "ERROR: OpenPnP build prerequisites must not be in the base ISO.\n" >&2
  exit 1
fi

printf "Base OS configuration validation passed. OpenPnP installation, ISO build, VM boot, persistence, and hardware compatibility are separate milestones.\n"
