# Build workflow: Codespaces and GitHub Actions

## Intended split

- **GitHub Codespaces:** edit configuration, run shell syntax checks, review logs, and prepare commits.
- **GitHub Actions:** run the privileged Debian Live build on a clean hosted Linux runner and publish the ISO only when all build and checksum steps pass.
- **VM / hardware:** boot the downloaded ISO in a UEFI virtual machine first; then test the actual Neway controller and cameras on the target PC.

Codespaces is a development container, not a guaranteed privileged VM. Debian Live builds use debootstrap and chroot/mount operations; do not assume the Codespaces container supports every operation needed for a full ISO build. The workflow is the authoritative clean-runner build.

## Run the workflow

1. Push a branch or open a pull request containing build configuration changes.
2. Open Actions → Build Neway PnP OS ISO.
3. Select Run workflow for a manual build, if enabled for the branch.
4. Wait for the entire job to succeed.
5. Download the neway-pnp-os-amd64 artifact. It contains the ISO and SHA256SUMS.
6. Verify locally with sha256sum -c SHA256SUMS from the directory containing both files.
7. Boot the ISO in a UEFI VM and complete tests/milestone-1-checklist.md.

## Current scope and limitations

This is the first build-pipeline scaffold, not a production image. The current package list establishes the minimal X11/OpenPnP runtime dependencies, but the automatic login/session, OpenPnP application payload, persistent machine data, crash recovery, and hardware validation still need to be implemented and tested before the ISO can be described as boot-to-OpenPnP.

Do not deploy this prototype to a production machine. The first successful ISO build proves only that the image-generation pipeline runs; it does not prove that OpenPnP launches or that camera/motion hardware works.

## Reproducibility

The workflow records the source commit in its artifact name and generates an ISO SHA-256 manifest. This is build-output integrity, not yet full bit-for-bit reproducibility: Debian package repositories and dependency versions are not snapshot-pinned in this first scaffold. Pinning snapshots and the OpenPnP application artifact is a separate acceptance gate before release.
