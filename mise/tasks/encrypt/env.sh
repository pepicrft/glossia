#!/usr/bin/env bash
#MISE description="Encrypts the .env file"

set -eo pipefail

sops encrypt -i --age "age1h5hshkkxdnfxz5sa0yp4hzlntehwzeey7kc8298znn6ve03q83tqegsxfy" .env.json
