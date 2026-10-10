# Neway PnP OS

Minimal Debian Trixie amd64 live ISO for Neway pick-and-place machines. This branch restarts the implementation from `main` with the requirements that **OpenPnP is included and auto-launched** and the final ISO must be **strictly smaller than 400,000,000 bytes**.

## Build design

- Debian Live `live-build`, `--variant=minbase`, APT recommends and indices disabled.
- Minimal Xorg/Openbox session; no full desktop environment.
- Upstream OpenPnP 2.6 is built in CI from its release tag. Maven and the JDK are build-only dependencies; only the runtime JAR and its dependency libraries are copied into the image.
- An unprivileged `neway` user autologs in on tty1. Openbox launches OpenPnP automatically.
- CI fails if the ISO is 400,000,000 bytes or larger, then checks SHA-256 before uploading.

## Download a build

Open the [GitHub Actions workflow](https://github.com/Virencq/neway-pnp-os/actions/workflows/build-iso.yml) and download the artifact from a successful run. Artifacts expire after seven days.

## Important validation status

A successful build and size check do not prove that the image boots or that camera and motion-controller hardware works. Before production use, test UEFI boot, display, camera capture, USB/serial connection, machine configuration storage and recovery on the actual Neway PC. This is a live ISO; persistence across reboot is not configured.

## Official references

- [Debian Live Manual — minimal image and package selection](https://live-team.pages.debian.net/live-manual/html/live-manual.en.html)
- [OpenPnP 2.6 release](https://github.com/openpnp/openpnp/releases/tag/2.6)
- [OpenPnP developer guide](https://github.com/openpnp/openpnp/wiki/Developers-Guide)
- [OpenPnP quick start](https://github.com/openpnp/openpnp/wiki/Quick-Start)

OpenPnP is GPL-3.0 licensed; see [LICENSES.md](LICENSES.md) for project licensing notes.
