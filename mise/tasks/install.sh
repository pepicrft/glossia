#!/usr/bin/env bash

set -eo pipefail

mix deps.get

if [ "$GITHUB_ACTIONS" = "true" ]; then
    mix ecto.setup
fi