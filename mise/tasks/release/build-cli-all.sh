#!/usr/bin/env bash
# mise description="Build CLI binaries for all platforms"

set -eo pipefail

VERSION="${1:-dev}"
OUTPUT_DIR="${2:-release}"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Platform configurations
declare -a PLATFORMS=(
  "linux/amd64"
  "linux/arm64"
  "linux/arm/7"
  "darwin/amd64"
  "darwin/arm64"
  "windows/amd64"
  "windows/arm64"
)

echo "Building CLI for version: $VERSION"

for platform in "${PLATFORMS[@]}"; do
  IFS='/' read -r goos goarch goarm <<< "$platform"
  
  # Set binary suffix
  suffix=""
  if [[ "$goos" == "windows" ]]; then
    suffix=".exe"
  fi
  
  # Set environment variables
  export GOOS=$goos
  export GOARCH=$goarch
  if [[ -n "$goarm" ]]; then
    export GOARM=$goarm
  fi
  
  # Build binary
  echo "Building for $goos/$goarch${goarm:+v$goarm}..."
  cd cli
  go build -ldflags="-s -w -X github.com/glossia/glossia/cli/cmd.version=${VERSION}" \
    -o "../$OUTPUT_DIR/glossia-${goos}-${goarch}${goarm:+v$goarm}${suffix}" \
    ./main.go
  cd ..
  
  # Unset GOARM if it was set
  unset GOARM
done

echo "All CLI binaries built successfully"