#!/usr/bin/env bash
#MISE description="Run the tests"

set -eo pipefail

mix local.hex --force
mix local.rebar --force
mix test
