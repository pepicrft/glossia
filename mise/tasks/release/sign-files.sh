#!/usr/bin/env bash
# mise description="Sign release files with GPG and minisign"

set -eo pipefail

RELEASE_DIR="${1:-release/archives}"

cd "$RELEASE_DIR"

# GPG signing (if key is available)
if [ -n "$GPG_PRIVATE_KEY" ]; then
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
if [ -n "$MINISIGN_PRIVATE_KEY" ] && [ -n "$MINISIGN_PASSWORD" ]; then
  echo "Minisign signing files..."
  
  # Check if minisign is installed
  if ! command -v minisign &> /dev/null; then
    echo "Installing minisign..."
    wget -q https://github.com/jedisct1/minisign/releases/download/0.11/minisign-0.11-linux.tar.gz
    tar xzf minisign-0.11-linux.tar.gz
    sudo mv minisign-linux/x86_64/minisign /usr/local/bin/
    rm -rf minisign-* 
  fi
  
  echo "$MINISIGN_PRIVATE_KEY" > ~/.minisign_key
  
  for file in *.tar.gz SHA256.txt SHA512.txt; do
    if [[ -f "$file" ]]; then
      echo "$MINISIGN_PASSWORD" | minisign -S -s ~/.minisign_key -m "$file" -x "${file}.minisig"
      echo "Signed with minisign: $file"
    fi
  done
  
  rm ~/.minisign_key
else
  echo "MINISIGN_PRIVATE_KEY or MINISIGN_PASSWORD not set, skipping minisign signing"
fi

cd - > /dev/null
echo "Signing completed"