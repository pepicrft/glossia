#!/usr/bin/env bash

set -eo pipefail

mix deps.get
pnpm -C assets/ install

if [ "$GITHUB_ACTIONS" != "true" ]; then
    mix ecto.setup
fi
