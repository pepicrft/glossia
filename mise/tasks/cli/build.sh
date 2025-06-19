#!/usr/bin/env bash
# mise description="Build the CLI"

set -eo pipefail

cd cli
go build -o glossia main.go