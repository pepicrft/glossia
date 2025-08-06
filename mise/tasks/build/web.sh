#!/usr/bin/env bash
# mise description="Build the web project"

set -eo pipefail

cd web
mix local.hex --force
mix local.rebar --force
mix compile --warnings-as-errors
