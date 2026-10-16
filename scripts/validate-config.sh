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
  config/hooks/live/9999-neway-security.hook.chroot
  config/includes.chroot/etc/ssh/sshd_config.d/60-neway-maintenance.conf
  config/includes.chroot/etc/systemd/system/ssh.service.d/10-neway-gate.conf
  config/includes.chroot/etc/systemd/system/ssh.socket.d/10-neway-gate.conf
  config/includes.chroot/usr/local/sbin/neway-machine-info
  config/includes.chroot/usr/local/sbin/neway-remote-maintenance-guard
  config/includes.chroot/usr/local/sbin/neway-enable-remote-maintenance
  config/includes.chroot/etc/NetworkManager/conf.d/20-neway-usb-tethering.conf
  config/includes.chroot/etc/NetworkManager/system-connections/Neway-wired-and-USB-tethering.nmconnection
  config/includes.chroot/etc/wireguard/README.neway
  config/includes.chroot/etc/nftables.conf
  config/includes.chroot/etc/nftables.d/neway-remote-access.nft
  docs/firewall-remote-access.nft
  docs/SECURITY-ARCHITECTURE.md
  docs/MACHINE-PROVISIONING.md
  scripts/build-iso.sh
  tests/test-machine-info.sh
  tests/test-remote-maintenance-guard.sh
)
for path in "${required[@]}"; do
  [[ -s "$path" ]] || { printf 'Missing required file: %s\n' "$path" >&2; exit 1; }
done

for package in openjdk-21-jre xinit openbox user-setup network-manager wireguard-tools openssh-server tpm2-tools gpgv nftables; do
  grep -Fxq "$package" config/package-lists/neway.list.chroot
done
if grep -Eq '^(maven|openjdk-21-jdk|git)$' config/package-lists/neway.list.chroot; then
  echo 'Build-only packages must not be installed in the final image.' >&2
  exit 1
fi
grep -q 'exec /usr/bin/java' config/includes.chroot/usr/local/bin/neway-openpnp
grep -q 'neway-openpnp' config/includes.chroot/etc/xdg/openbox/autostart
grep -q 'ConditionPathExists=/etc/neway/maintenance-enabled' config/includes.chroot/etc/systemd/system/ssh.service.d/10-neway-gate.conf
grep -q 'iifname != "wg0" tcp dport 22 drop' config/includes.chroot/etc/nftables.d/neway-remote-access.nft
grep -q 'iifname != "wg0" tcp dport 22 drop' docs/firewall-remote-access.nft
bash -n scripts/build-iso.sh scripts/validate-config.sh
bash -n config/hooks/live/9998-neway-operator.hook.chroot config/hooks/live/9999-neway-security.hook.chroot
bash -n config/includes.chroot/usr/local/sbin/neway-machine-info
bash -n config/includes.chroot/usr/local/sbin/neway-remote-maintenance-guard
bash -n config/includes.chroot/usr/local/sbin/neway-enable-remote-maintenance
bash -n tests/test-machine-info.sh tests/test-remote-maintenance-guard.sh
bash tests/test-machine-info.sh
bash tests/test-remote-maintenance-guard.sh
printf '%s\n' 'Neway OpenPnP OS configuration and security scaffolding validation passed.'
