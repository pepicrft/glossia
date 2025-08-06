#!/usr/bin/env bash
# mise description="Create UBI-compliant release archives"

set -eo pipefail

VERSION="${1:-dev}"
INPUT_DIR="${2:-release/binaries}"
OUTPUT_DIR="${3:-release}"

# Convert to absolute path before changing directory
OUTPUT_DIR="$(cd "$(dirname "$OUTPUT_DIR")" && pwd)/$(basename "$OUTPUT_DIR")"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

cd "$INPUT_DIR"

# Create archives for each binary
for binary in glossia-*; do
  if [[ -f "$binary" ]]; then
    # Extract platform info from filename
    platform_info="${binary#glossia-}"
    
    # Determine archive name based on UBI convention
    archive_name=""
    case "$platform_info" in
      linux-amd64)
        archive_name="glossia-x86_64-unknown-linux-gnu.tar.gz"
        ;;
      linux-arm64)
        archive_name="glossia-aarch64-unknown-linux-gnu.tar.gz"
        ;;
      linux-armv7)
        archive_name="glossia-armv7-unknown-linux-gnueabihf.tar.gz"
        ;;
      darwin-amd64)
        archive_name="glossia-x86_64-apple-darwin.tar.gz"
        ;;
      darwin-arm64)
        archive_name="glossia-aarch64-apple-darwin.tar.gz"
        ;;
      windows-amd64.exe)
        archive_name="glossia-x86_64-pc-windows-msvc.tar.gz"
        binary_name="glossia.exe"
        ;;
      windows-arm64.exe)
        archive_name="glossia-aarch64-pc-windows-msvc.tar.gz"
        binary_name="glossia.exe"
        ;;
      *)
        echo "Unknown platform: $platform_info"
        continue
        ;;
    esac
    
    # Rename binary for archive (Windows needs .exe, others just glossia)
    if [[ "$platform_info" == windows-* ]]; then
      cp "$binary" "glossia.exe"
      tar czf "$OUTPUT_DIR/$archive_name" "glossia.exe"
      rm "glossia.exe"
    else
      cp "$binary" "glossia"
      tar czf "$OUTPUT_DIR/$archive_name" "glossia"
      rm "glossia"
    fi
    
    echo "Created archive: $archive_name"
  fi
done

cd ..
echo "All archives created successfully"