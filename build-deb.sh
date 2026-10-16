#!/usr/bin/env bash
#
# build-deb.sh - Build a Debian package (.deb) for this custom OpenPnP build.
#
# Usage:
#   ./build-deb.sh              # build jar if missing, then package
#   ./build-deb.sh --rebuild    # always rebuild jar with maven, then package
#   ./build-deb.sh --package-only  # package existing target/openpnp.jar only
#
# Output: ./dist/openpnp-custom_<version>_all.deb
#
# Requires: default-jdk, maven, dpkg-deb (all standard Debian packages).
#
set -euo pipefail

PKG_NAME="openpnp-custom"
DESCRIPTION="OpenPnP pick and place software (custom pnp-xp build)"
MAINTAINER="OpenPnP Custom Build <root@localhost>"
INSTALL_DIR="/opt/openpnp"
JAVA_DEP="default-jre | java17-runtime | java11-runtime"

cd "$(dirname "$0")"

# ---------------------------------------------------------------------------
# Version: 0.0.1alpha~<yyyymmdd>~g<git-hash>  (always a valid Debian version)
# ---------------------------------------------------------------------------
GIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "nogit")
BUILD_DATE=$(date +%Y%m%d)
VERSION="0.0.1alpha~${BUILD_DATE}~g${GIT_HASH}"

# ---------------------------------------------------------------------------
# 1. Build the jar
# ---------------------------------------------------------------------------
MODE="${1:-}"
if [ "$MODE" = "--rebuild" ] || { [ "$MODE" != "--package-only" ] && [ ! -f target/openpnp.jar ]; }; then
    echo "==> Building OpenPnP with Maven..."
    mvn clean package -DskipTests
fi

JAR_FILE="$(find target -maxdepth 1 -type f -name 'openpnp-gui-*.jar' ! -name '*sources*' ! -name '*javadoc*' | sort | head -n 1)"
if [ -z "$JAR_FILE" ] && [ -f target/openpnp.jar ]; then
    JAR_FILE="target/openpnp.jar"
fi

if [ -z "$JAR_FILE" ] || [ ! -d target/lib ]; then
    echo "ERROR: OpenPnP application JAR or target/lib missing. Run with --rebuild." >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# 2. Stage the package tree
# ---------------------------------------------------------------------------
STAGE="dist/pkg"
rm -rf "$STAGE"
mkdir -p "$STAGE$INSTALL_DIR/lib" \
         "$STAGE/usr/bin" \
         "$STAGE/usr/share/applications" \
         "$STAGE/usr/share/pixmaps" \
         "$STAGE/DEBIAN"

echo "==> Staging files..."
install -m 0644 "$JAR_FILE" "$STAGE$INSTALL_DIR/openpnp.jar"
cp -r target/lib/. "$STAGE$INSTALL_DIR/lib/"

# Launcher
cat > "$STAGE/usr/bin/openpnp" << EOF
#!/bin/sh
exec java -jar $INSTALL_DIR/openpnp.jar "\$@"
EOF
chmod 755 "$STAGE/usr/bin/openpnp"

# Desktop entry
cat > "$STAGE/usr/share/applications/openpnp.desktop" << EOF
[Desktop Entry]
Type=Application
Name=OpenPnP (custom)
Comment=Open Source SMT Pick and Place
Exec=openpnp
Icon=openpnp
Terminal=false
Categories=Development;Engineering;
EOF

# Icon (optional - downloaded from the openpnp-logo repo)
if command -v curl > /dev/null 2>&1; then
    curl -fsSL -o "$STAGE/usr/share/pixmaps/openpnp.png" \
        https://raw.githubusercontent.com/openpnp/openpnp-logo/develop/logo_small.png || \
        echo "WARN: could not download icon, packaging without it."
fi

# ---------------------------------------------------------------------------
# 3. DEBIAN control files
# ---------------------------------------------------------------------------
INSTALLED_SIZE=$(du -sk "$STAGE/opt" "$STAGE/usr" | awk '{s+=$1} END {print s}')

cat > "$STAGE/DEBIAN/control" << EOF
Package: $PKG_NAME
Version: $VERSION
Section: electronics
Priority: optional
Architecture: all
Installed-Size: $INSTALLED_SIZE
Depends: $JAVA_DEP
Maintainer: $MAINTAINER
Description: $DESCRIPTION
 Custom build of OpenPnP from the pnp-xp-custom branch, including
 local modifications. Installs to $INSTALL_DIR and provides the
 'openpnp' command and a desktop menu entry.
 .

 Machine configuration and calibration data are stored separately in
 ~/.openpnp2 and are never touched by this package.
EOF

# postinst: remind about serial-port permissions
cat > "$STAGE/DEBIAN/postinst" << 'EOF'
#!/bin/sh
set -e
case "$1" in
    configure)
        echo ""
        echo "OpenPnP custom build installed."
        echo "NOTE: to use the machine controller without root, add your user"
        echo "to the dialout group and re-login:"
        echo ""
        echo "    sudo usermod -aG dialout \$USER"
        echo ""
        ;;
esac
# DEBHELPER#
exit 0
EOF
chmod 755 "$STAGE/DEBIAN/postinst"

# prerm: clean launchers only (jar/lib removed automatically by dpkg)
cat > "$STAGE/DEBIAN/prerm" << 'EOF'
#!/bin/sh
set -e
exit 0
EOF
chmod 755 "$STAGE/DEBIAN/prerm"

# ---------------------------------------------------------------------------
# 4. Build the .deb
# ---------------------------------------------------------------------------
mkdir -p dist
DEB="dist/${PKG_NAME}_${VERSION}_all.deb"
echo "==> Building $DEB ..."
dpkg-deb --build --root-owner-group "$STAGE" "$DEB"

echo ""
echo "Done: $DEB"
echo "Install with:  sudo apt install ./$DEB"
echo "              (apt resolves the Java dependency automatically)"
