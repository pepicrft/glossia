#!/usr/bin/env bash

set -eo pipefail

# Install web dependencies if web directory exists and has mix.exs
if [ -f "web/mix.exs" ]; then
    cd web
    mix deps.get
    
    if [ "$GITHUB_ACTIONS" != "true" ]; then
        mix ecto.setup
    fi
    cd ..
fi

# Install CLI dependencies if cli directory exists and has go.mod
if [ -f "cli/go.mod" ]; then
    cd cli
    go mod download
    cd ..
fi
