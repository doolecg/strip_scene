#!/usr/bin/env bash
# Builds StripScene.mzp from the source files, with Windows line endings for Max.
set -euo pipefail
cd "$(dirname "$0")"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
for f in mzp.run install.ms StripScene.mcr; do sed 's/\r$//; s/$/\r/' "$f" > "$tmp/$f"; done
rm -f StripScene.mzp
(cd "$tmp" && zip -q -X "$OLDPWD/StripScene.mzp" mzp.run install.ms StripScene.mcr)
echo "Built StripScene.mzp"
