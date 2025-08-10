#!/usr/bin/env bash
#MISE description="Run daemon code checks"
#USAGE flag "-f --fix" help="Fixes the fixable issues"

set -eo pipefail

cd daemon

if [ "$usage_fix" = "true" ]; then
    mix format
else
    mix format --check-formatted
    mix credo suggest
fi