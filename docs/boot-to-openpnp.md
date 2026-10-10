# Boot-to-OpenPnP prototype

## Current phase: base OS only

- Target: Debian Trixie amd64 live ISO for Intel/AMD x86-64 PCs.
- Phase 1 installs a minimal Xorg + Openbox environment and creates the unprivileged `neway` operator account.
- The system autologs into `neway` on tty1 and starts the Openbox session.
- OpenPnP is deliberately **not installed or built** in this phase. There is no Maven build or upstream OpenPnP checkout in the ISO build.
- The live ISO is a prototype, not an SSD installer. Session changes normally disappear after reboot unless persistence is configured.

## Later phase: install OpenPnP

After the base ISO builds and passes a UEFI VM boot test:

1. Identify your customized OpenPnP source tree using `git status`, `git remote -v`, and `git rev-parse HEAD`.
2. Commit and push the intended source to a repository you control; do not include secrets, machine passwords, API keys, or customer data.
3. Pin the installer to a full immutable commit SHA or a verified upstream release.
4. Create a separate installer/package that installs the Java runtime, OpenPnP application and dependencies without rebuilding the operating system image every time.
5. Test camera, USB/serial controller permissions, machine configuration storage, update and recovery behavior on the actual Neway PC.

Do not treat an ISO build as proof of hardware compatibility. Do not use the prototype for production machine motion until UEFI boot, persistence, camera/serial checks, and controller validation pass.

## Official references

- [Debian Live Manual](https://live-team.pages.debian.net/live-manual/)
- [Debian live-build package](https://packages.debian.org/stable/live-build)
- [OpenPnP releases](https://github.com/openpnp/openpnp/releases)
- [OpenPnP Quick Start](https://github.com/openpnp/openpnp/wiki/Quick-Start)
