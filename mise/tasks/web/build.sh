#!/usr/bin/env bash
# mise description="Build the web project"

set -eo pipefail

cd web && mix compile --warnings-as-errors
