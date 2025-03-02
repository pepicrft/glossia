#!/usr/bin/env bash
# mise description="Build the project"

set -eo pipefail

mix compile --warnings-as-errors
