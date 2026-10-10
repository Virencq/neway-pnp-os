# Third-party licenses and notices

This repository assembles an operating-system image containing Debian packages and upstream OpenPnP. Each component retains its own license; this file tracks obligations but does not replace upstream license texts.

## OpenPnP

- **Version:** 2.6
- **Source commit:** `5bd404cfc70f34103a3ca0fbb6b50c2b465f407c`
- **Source:** https://github.com/openpnp/openpnp
- **License:** GPL-3.0 (see upstream `LICENSE.txt`)
- **Build method:** source is fetched by immutable commit and compiled into the image; source is not embedded in the ISO at this stage.

Before redistributing an image containing OpenPnP, ensure the corresponding source is made available as required by GPL-3.0, retain required notices, and review the license terms of every bundled dependency.

## Debian and other dependencies

The final package manifest must be captured from the built image and reviewed before any production distribution. Include at least the Debian base/kernel, Java runtime, OpenCV/native libraries, Xorg/Openbox, firmware, and all packages pulled in by dependencies.

For every redistributed component, record exact version, source URL, license identifier/text, copyright notices, modifications, and source-availability obligations. Do not publish a production image until this inventory is complete.
