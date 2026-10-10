# Build workflow: Codespaces and GitHub Actions

## Intended split

- **GitHub Codespaces:** edit configuration, run syntax checks, review logs, and prepare commits.
- **GitHub Actions:** run the privileged Debian Live build on a clean hosted Linux runner and publish the ISO only when all build and checksum steps pass.
- **VM / hardware:** boot the downloaded ISO in a UEFI virtual machine first; then test the actual Neway controller and cameras on the target PC.

Codespaces is a development container, not a guaranteed privileged VM. Debian Live builds use debootstrap and chroot/mount operations; do not assume the Codespaces container supports every operation needed for a full ISO build. The workflow is the clean-runner build path.

## Run the workflow

1. Open the pull request or repository's Actions tab.
2. Select **Build Neway PnP OS ISO** and run it manually if workflow dispatch is available; PR updates should also trigger it when relevant files change.
3. Wait for the entire job to succeed, including the OpenPnP source build inside the chroot.
4. Download the `neway-pnp-os-amd64-<commit>` artifact. It contains the ISO and `SHA256SUMS`.
5. Verify locally with `sha256sum -c SHA256SUMS` from the directory containing both files.
6. Boot the ISO in a UEFI VM and complete `tests/milestone-1-checklist.md`.

## Current implementation and limitations

The active implementation pins upstream OpenPnP 2.6 to commit `5bd404cfc70f34103a3ca0fbb6b50c2b465f407c`, builds it with Maven during the image build, creates an unprivileged `neway` operator, and launches OpenPnP automatically from a minimal X11/Openbox session. Startup logs are written to `/home/neway/.local/state/neway/openpnp.log`, and restarts are bounded.

This remains a **live ISO prototype**, not a production image or SSD installer. Configuration changes normally disappear when the live session reboots unless persistence is configured. Maven dependency repositories are not snapshot-locked, so the build is not yet bit-for-bit reproducible. The source pin does not replace review of third-party dependency licenses.

A successful ISO build proves only that image generation succeeded. It does not prove that the ISO boots, that OpenPnP's GUI works on the target GPU, or that the cameras and motion controller work. Do not deploy this prototype to a production machine.

## Reproducibility and source pinning

The OpenPnP Git source commit is immutable and verified by the chroot hook. Debian Trixie is selected as the distribution, but package versions are not pinned to a Debian snapshot. Maven dependencies are also resolved from configured upstream repositories. These are known reproducibility gaps to close before a release.
