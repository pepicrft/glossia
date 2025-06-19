#!/usr/bin/env bash
# mise description="Run CLI tests"

set -eo pipefail

cd cli
go test -v ./...