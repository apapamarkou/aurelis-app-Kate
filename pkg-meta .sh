#!/bin/sh
# pkg-meta.sh <arch-package> [file.AppImage]
# Τρέχει ΜΕΣΑ στο Arch container, μετά το `quick-sharun --make-appimage`.
# Βάζει στο $OUTPATH (default ./dist):  <pkg>-<arch>.json, <appimage>.sha256,
# <pkg>.png|svg, *.desktop, *.metainfo.xml / *.appdata.xml
set -eu

PKG=${1:?usage: pkg-meta.sh <arch-package> [file.AppImage]}
OUT=${OUTPATH:-./dist}
APPDIR=${APPDIR:-./AppDir}
ARCH=${ARCH:-$(uname -m)}
AI=${2:-$(ls "$OUT"/*.AppImage | head -n1)}
AIF=${AI##*/}
mkdir -p "$OUT"

# --- helpers ---------------------------------------------------------------
je() { printf '%s' "$1" | tr '\n\t' '  ' | sed 's/\\/\\\\/g; s/"/\\"/g'; }
pi() { LC_ALL=C pacman -Qi "$PKG" | sed -n "s/^$1 *: //p" | head -n1; }
jarr() { # args: λίστα αρχείων -> ["a","b"]
	out=
	for x; do out="$out${out:+,}\"$(je "${x##*/}")\""; done
	printf '[%s]' "$out"
}
dkey() { sed -n "s/^$2=//p" "$1" | head -n1; }   # non-localized key από .desktop

# --- 1. SHA256 -------------------------------------------------------------
SHA=$(sha256sum "$AI" | cut -d' ' -f1)
( cd "$OUT" && printf '%s  %s\n' "$SHA" "$AIF" > "$AIF.sha256" )
SIZE=$(stat -c %s "$AI")

# --- 2. .desktop -----------------------------------------------------------
DESKTOPS=
for f in "$APPDIR"/*.desktop "$APPDIR"/share/applications/*.desktop; do
	[ -f "$f" ] && DESKTOPS="$DESKTOPS $f"
done
[ -n "$DESKTOPS" ] || { [ -f "${DESKTOP:-}" ] && DESKTOPS=$DESKTOP; }
[ -n "$DESKTOPS" ] || echo "WARN: no .desktop found" >&2
DLIST=
for f in $DESKTOPS; do cp -f "$f" "$OUT/"; DLIST="$DLIST $OUT/${f##*/}"; done
MAIN=${DESKTOPS%% *}; MAIN=${MAIN# }
[ -z "$MAIN" ] && MAIN=$(echo $DESKTOPS | cut -d' ' -f1)

# --- 3. icon ---------------------------------------------------------------
ICONF=
if [ -e "$APPDIR/.DirIcon" ]; then ICONF=$(readlink -f "$APPDIR/.DirIcon" || true); fi
case "$ICONF" in *.png|*.svg) ;; *)
	ICONF=
	for f in "$APPDIR"/*.png "$APPDIR"/*.svg; do [ -f "$f" ] && { ICONF=$f; break; }; done ;;
esac
ICONNAME=
if [ -n "$ICONF" ]; then
	ICONNAME="$PKG.${ICONF##*.}"; cp -fL "$ICONF" "$OUT/$ICONNAME"
else echo "WARN: no icon found" >&2; fi

# --- 4. AppStream ----------------------------------------------------------
METAS=$(pacman -Ql "$PKG" | awk '{print $2}' | grep -E '/usr/share/(metainfo|appdata)/[^/]+\.xml$' || true)
MLIST=
for f in $METAS; do cp -f "$f" "$OUT/"; MLIST="$MLIST $OUT/${f##*/}"; done
MAINM=$(echo $MLIST | cut -d' ' -f1)
AS_NAME=; AS_SUM=; AS_ID=
if [ -n "$MAINM" ]; then
	AS_ID=$(sed -n 's|.*<id>\(.*\)</id>.*|\1|p' "$MAINM" | head -n1)
	AS_NAME=$(sed -n 's|^ *<name>\(.*\)</name>.*|\1|p' "$MAINM" | head -n1)
	AS_SUM=$(sed -n 's|^ *<summary>\(.*\)</summary>.*|\1|p' "$MAINM" | head -n1)
fi

# --- 5. URL (χωρίς API: κλασικά release download links) --------------------
REPO=${GITHUB_REPOSITORY:-}
if [ "${DEVEL_RELEASE-}" = 1 ]; then TAGPATH=download/nightly; else TAGPATH=latest/download; fi
BASE=
[ -n "$REPO" ] && BASE="https://github.com/$REPO/releases/$TAGPATH"

# --- 6. JSON ---------------------------------------------------------------
J="$OUT/$PKG-$ARCH.json"
cat > "$J" <<JSON
{
  "pkg": "$(je "$PKG")",
  "arch": "$(je "$ARCH")",
  "version": "$(je "$(pi Version)")",
  "description": "$(je "$(pi Description)")",
  "upstream_url": "$(je "$(pi URL)")",
  "licenses": "$(je "$(pi Licenses)")",
  "packager": "$(je "$(pi Packager)")",
  "build_date": "$(je "$(pi 'Build Date')")",
  "installed_size": "$(je "$(pi 'Installed Size')")",
  "appstream": {
    "id": "$(je "$AS_ID")",
    "name": "$(je "$AS_NAME")",
    "summary": "$(je "$AS_SUM")"
  },
  "desktop": {
    "name": "$(je "$([ -n "$MAIN" ] && dkey "$MAIN" Name)")",
    "comment": "$(je "$([ -n "$MAIN" ] && dkey "$MAIN" Comment)")",
    "categories": "$(je "$([ -n "$MAIN" ] && dkey "$MAIN" Categories)")",
    "files": $(jarr $DLIST)
  },
  "metainfo_files": $(jarr $MLIST),
  "icon": "$(je "$ICONNAME")",
  "appimage": {
    "file": "$(je "$AIF")",
    "size": $SIZE,
    "sha256": "$SHA",
    "url": "$(je "${BASE:+$BASE/}$AIF")"
  },
  "generated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
JSON
echo "pkg-meta: wrote $J"
