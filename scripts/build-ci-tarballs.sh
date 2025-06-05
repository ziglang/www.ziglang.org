#!/bin/bash
set -euo pipefail

CI_TARBALLS_DIR="ci-tarballs"
MAX_FILES=20

mkdir -p "$CI_TARBALLS_DIR"

# Create a dummy tarball file with timestamp
TIMESTAMP=$(date +%s%3N)
TARBALL_NAME="ci-update-$TIMESTAMP.tar.xz"
TARBALL_PATH="$CI_TARBALLS_DIR/$TARBALL_NAME"

echo "Dummy tarball content for CI update" > "$TARBALL_PATH"
echo "Created CI tarball: $TARBALL_NAME"

# Delete older tarballs, keep only the most recent $MAX_FILES
cd "$CI_TARBALLS_DIR"
ls -1t ci-update-*.tar.xz | tail -n +$((MAX_FILES + 1)) | xargs -r rm --
echo "Deleted old CI tarballs, kept most recent $MAX_FILES files."
