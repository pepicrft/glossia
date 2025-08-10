#!/usr/bin/env bash
#MISE description="Run daemon tests"

set -eo pipefail

cd daemon

mix test