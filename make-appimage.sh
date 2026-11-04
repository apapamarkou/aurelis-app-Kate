#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q kate | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export ICON=https://invent.kde.org/utilities/kate/-/raw/master/apps/kate/icons/unix/256-apps-kate.png?ref_type=heads
export DESKTOP=/usr/share/applications/org.kde.kate.desktop
export STARTUPWMCLASS=org.kde.kate
export USE_HOST_DRIVERS_EXPERIMENTAL=1
export DEPLOY_KF=1

# Deploy dependencies
quick-sharun \
  /usr/bin/kate \
  /usr/bin/kwrite \
  /usr/bin/exec_inspect.sh \
  /usr/share/kdevappwizard \
  /usr/share/color-schemes \
  /usr/share/kstyle \
  /usr/share/kateproject \
  /usr/share/katexmltools \
  /usr/share/org.kde.syntax-highlighting

mkdir -p ./AppDir/share/applications
cp /usr/share/applications/org.kde.kwrite.desktop ./AppDir/share/applications

# Turn AppDir into AppImage
GITHUB_REPOSITORY= quick-sharun --make-appimage
rm -f ./dist/*.zsync
sh ./pkg-meta.sh kate

# Test the app for 12 seconds, if the app normally quits before that time
# then skip this or check if some flag can be passed that makes it stay open
quick-sharun --simple-test ./dist/*.AppImage

echo "============================================="
echo "============================================="
./dist/*.AppImage --appimage-updateinformation || true
ls ./AppDir/bin | grep -i updater || echo "no updater hook"
echo "============================================="
echo "============================================="