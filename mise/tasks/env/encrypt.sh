#!/usr/bin/env bash
# mise description="Encrypts the .env file"

set -eo pipefail

sops encrypt -i --age "age1cqmmqks8fqytf5vgcg6xy2uxske5efd9yvvstcpxn3vg9clxddxsjxx8cw" .env.json
