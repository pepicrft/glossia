#!/usr/bin/env bash
# mise description="Sign release files with GPG and minisign"

set -euo pipefail

RELEASE_DIR="${1:-release/archives}"

# Check if directory exists
if [ ! -d "$RELEASE_DIR" ]; then
  echo "Warning: Release directory $RELEASE_DIR does not exist, skipping signing"
  exit 0
fi

cd "$RELEASE_DIR"

# Check if there are any files to sign
if ! ls *.tar.gz &>/dev/null && ! ls SHA*.txt &>/dev/null; then
  echo "No files to sign in $RELEASE_DIR, skipping"
  exit 0
fi

# GPG signing (if key is available)
if [ -n "${GPG_PRIVATE_KEY:-}" ]; then
  echo "GPG signing files..."
  echo "$GPG_PRIVATE_KEY" | gpg --batch --import
  
  for file in *.tar.gz SHA256.txt SHA512.txt; do
    if [[ -f "$file" ]]; then
      gpg --batch --yes --detach-sign --armor --output "${file}.asc" "$file"
      echo "Signed with GPG: $file"
    fi
  done
else
  echo "GPG_PRIVATE_KEY not set, skipping GPG signing"
fi

# Minisign signing (if key is available)
if [ -n "${MINISIGN_PRIVATE_KEY:-}" ] && [ -n "${MINISIGN_PASSWORD:-}" ]; then
  echo "Minisign signing files..."
  
  # Check if minisign is installed
  if ! command -v minisign &> /dev/null; then
    echo "Installing minisign..."
    MINISIGN_VERSION="0.11"
    MINISIGN_URL="https://github.com/jedisct1/minisign/releases/download/${MINISIGN_VERSION}/minisign-${MINISIGN_VERSION}-linux.tar.gz"
    MINISIGN_SHA256="74fb06dd59c36c139c7651dddc208207cc7477aa7fb17e8076cba57c957f0e97"
    
    wget -q "$MINISIGN_URL" -O minisign.tar.gz
    echo "${MINISIGN_SHA256}  minisign.tar.gz" | sha256sum -c -
    tar xzf minisign.tar.gz
    
    # Install to current directory and use from there
    mv minisign-linux/x86_64/minisign ./minisign
    chmod +x ./minisign
    MINISIGN_CMD="./minisign"
    rm -rf minisign-linux minisign.tar.gz
  else
    MINISIGN_CMD="minisign"
  fi
  
  # Create temporary key file with proper permissions
  MINISIGN_KEY_FILE=$(mktemp)
  chmod 600 "$MINISIGN_KEY_FILE"
  trap 'rm -f "$MINISIGN_KEY_FILE"' EXIT
  echo "$MINISIGN_PRIVATE_KEY" > "$MINISIGN_KEY_FILE"
  
  for file in *.tar.gz SHA256.txt SHA512.txt; do
    if [[ -f "$file" ]]; then
      echo "$MINISIGN_PASSWORD" | $MINISIGN_CMD -S -s "$MINISIGN_KEY_FILE" -m "$file" -x "${file}.minisig"
      echo "Signed with minisign: $file"
    fi
  done
  
  rm -f "$MINISIGN_KEY_FILE"
  trap - EXIT
else
  echo "MINISIGN_PRIVATE_KEY or MINISIGN_PASSWORD not set, skipping minisign signing"
fi

cd - > /dev/null

# Provide summary
if [ -n "${GPG_PRIVATE_KEY:-}" ] || [ -n "${MINISIGN_PRIVATE_KEY:-}" ]; then
  echo "Signing completed successfully"
else
  echo "No signing keys available, skipping file signing (this is normal for external contributors)"
fi