#!/usr/bin/env bash
# mise description="Dev the web project"

set -eo pipefail

cd web
mix local.hex --force
mix local.rebar --force
mix phx.server
