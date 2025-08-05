#!/usr/bin/env bash
# mise description="Lint CLI code"

set -eo pipefail

cd cli
go fmt ./...
go vet ./...