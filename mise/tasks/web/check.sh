#!/usr/bin/env bash
#MISE description="Run web code checks"
#USAGE flag "-f --fix" help="Fixes the fixable issues"

set -eo pipefail

cd web
mix local.hex --force
mix local.rebar --force

if [ "$usage_fix" = "true" ]; then
    mix format
    mix gettext.extract --merge --locale en
else
    mix format --check-formatted
    mix credo suggest
    mix gettext.extract --check-up-to-date
fi
