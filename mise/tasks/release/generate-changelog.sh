#!/usr/bin/env bash
# mise description="Generate changelog for a release"

set -eo pipefail

OUTPUT_FILE="${1:-CHANGELOG.md}"
VERSION="${2:-}"

if [ -n "$VERSION" ]; then
  # Generate changelog for specific version (only changes since last tag)
  git-cliff --unreleased --tag "$VERSION" --strip header > "$OUTPUT_FILE"
  echo "Generated changelog for version $VERSION"
else
  # Generate changelog for latest release
  git-cliff --latest --strip header > "$OUTPUT_FILE"
  echo "Generated changelog for latest release"
fi

echo "Changelog saved to: $OUTPUT_FILE"