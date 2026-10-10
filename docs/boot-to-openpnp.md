# Boot-to-OpenPnP prototype

## Current design

- Target: Debian Trixie amd64 live ISO for Intel/AMD x86-64 PCs.
- Application source is selected in `config/includes.chroot/etc/neway/openpnp-source.conf` by an HTTPS Git URL and a full immutable 40-character commit SHA.
- The default source is upstream OpenPnP. To use a customized build, point this file to your fork/repository and the exact commit containing your modifications.
- Build: OpenPnP is compiled during the live-build chroot stage; the hook verifies the checked-out commit matches the configured SHA before compilation.
- Runtime: dedicated unprivileged `neway` account, tty1 autologin, Xorg + Openbox, then OpenPnP. There is no GNOME/KDE desktop.
- Recovery: OpenPnP output is appended to `/home/neway/.local/state/neway/openpnp.log`. The launcher bounds automatic restarts.
- Machine data: OpenPnP's normal per-user configuration is kept under `/home/neway/.openpnp`.

## Use a customized OpenPnP source tree

1. On your PC, check your local source tree with `git status`. Commit your intended modifications to a dedicated branch so the exact source can be identified and rebuilt.
2. Push that branch to a Git repository you control (a fork of OpenPnP is suitable). Do not upload secrets, machine passwords, API keys, or customer data.
3. Copy the full commit SHA from GitHub for the commit containing your modifications. Do not use a moving branch name as the build pin.
4. Edit `config/includes.chroot/etc/neway/openpnp-source.conf` on branch `feat/boot-to-openpnp`:
   - `OPENPNP_REPOSITORY`: your repository's HTTPS clone URL ending in `.git`.
   - `OPENPNP_COMMIT`: the exact 40-character commit SHA.
5. Commit/push the configuration change to `feat/boot-to-openpnp`. The existing pull request will update automatically; do not merge it into `main`.
6. Check Actions. The hook fetches only the pinned commit, builds it with Maven, and fails if the fetched commit differs or if the expected JAR/library outputs are missing.

Example configuration (replace both values with your own real repository and SHA):

```bash
OPENPNP_REPOSITORY="https://github.com/YOUR-ACCOUNT/openpnp.git"
OPENPNP_COMMIT="0123456789abcdef0123456789abcdef01234567"
```

The placeholder SHA above is an example format only and will not pass the build unless replaced with the real commit SHA. If your source repository is private, the current unauthenticated ISO build cannot fetch it; do not put a personal access token in this file. We should configure a narrowly scoped GitHub Actions secret and authenticated checkout before building private source.

## Build requirements and limitations

The image build needs network access to GitHub and Maven repositories. Maven dependency versions are not yet snapshot-locked, so the build is not bit-for-bit reproducible. OpenPnP and dependencies retain their own licenses; review applicable license/source-distribution obligations before distributing an image containing your modified version.

This is a live ISO prototype, not an installer. Live-session changes—including machine configuration—are normally lost on reboot unless a supported persistence device/partition is configured. Do not use it for production machine motion until persistence, UEFI VM boot, camera/serial checks, and Neway controller validation have passed.

## First validation

1. Run the GitHub Actions workflow and inspect the complete log; the OpenPnP build hook must complete.
2. Download the ISO artifact and verify its SHA-256 manifest.
3. Boot in a UEFI VM. Confirm it reaches OpenPnP without manual login and that no desktop shell is presented.
4. Confirm the OpenPnP log is created and simulate a launch failure to validate bounded restart behavior.
5. Validate configuration retention and recovery separately; a successful live ISO build alone does not prove either.
