#!/usr/bin/env bash
# mise description="Run the web tests"

set -eo pipefail

cd web && mix test
