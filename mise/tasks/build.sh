#!/usr/bin/env bash
#MISE description="Build the project"

set -eo pipefail

mix local.hex --force
mix local.rebar --force
mix compile --warnings-as-errors
