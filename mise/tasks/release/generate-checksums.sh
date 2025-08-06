#!/usr/bin/env bash
# mise description="Generate SHA256 and SHA512 checksums for release files"

set -eo pipefail

RELEASE_DIR="${1:-release/archives}"

cd "$RELEASE_DIR"

# Generate SHA256 checksums
if ls *.tar.gz 1> /dev/null 2>&1; then
  echo "Generating SHA256 checksums..."
  sha256sum *.tar.gz > SHA256.txt
  echo "SHA256.txt created"
else
  echo "No tar.gz files found to checksum"
  exit 1
fi

# Generate SHA512 checksums  
echo "Generating SHA512 checksums..."
sha512sum *.tar.gz > SHA512.txt
echo "SHA512.txt created"

cd - > /dev/null
echo "Checksums generated successfully"