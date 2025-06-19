#!/usr/bin/env bash
# mise description="Run the web tests"

set -eo pipefail

cd web
mix local.hex --force
mix local.rebar --force
mix test
