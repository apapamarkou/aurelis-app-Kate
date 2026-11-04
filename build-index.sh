#!/bin/sh
# build-index.sh repos.txt [arch]
# repos.txt: μία γραμμή ανά project:  owner/repo  arch-package   (π.χ. "aurelis/aurelis-app-Kate kate")
# Κατεβάζει <pkg>-<arch>.json από το latest release κάθε repo (plain github.com, ΟΧΙ api.github.com)
# και γράφει index.json (+ index.json.sha256). Χρειάζεται curl + jq.
set -eu
LIST=${1:?usage: build-index.sh repos.txt [arch]}
ARCH=${2:-x86_64}
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

grep -Ev '^\s*(#|$)' "$LIST" | xargs -P 16 -L1 sh -c '
	url="https://github.com/$0/releases/latest/download/$1-'"$ARCH"'.json"
	curl -fsSL --retry 3 --max-time 30 "$url" -o "'"$TMP"'/$(echo "$0" | tr / _)__$1.json" \
		|| echo "SKIP $0 ($url)" >&2
'
jq -s 'sort_by(.pkg)' "$TMP"/*.json > index.json
sha256sum index.json > index.json.sha256
echo "index.json: $(jq length index.json) packages"
