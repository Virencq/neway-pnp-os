#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

required_files=(
  "config/package-lists/neway.list.chroot"
  "scripts/build-iso.sh"
)
for path in "${required_files[@]}"; do
  if [[ ! -s "$path" ]]; then
    printf 'ERROR: required file missing or empty: %s\n' "$path" >&2
    exit 1
  fi
done

if grep -RniE 'TODO|REPLACE_ME|CHANGEME' config scripts; then
  printf 'ERROR: unresolved placeholder found in build configuration.\n' >&2
  exit 1
fi

if ! grep -Eq '^openjdk-17-jre$' config/package-lists/neway.list.chroot; then
  printf 'ERROR: expected Java runtime package is missing.\n' >&2
  exit 1
fi

printf 'Configuration validation passed. This check does not prove ISO boot or hardware compatibility.\n'
