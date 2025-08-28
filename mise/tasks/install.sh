#!/usr/bin/env bash

set -eo pipefail

mix deps.get
pnpm install

if [ "$GITHUB_ACTIONS" != "true" ]; then
    mix ecto.setup
fi
