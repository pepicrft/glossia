#!/usr/bin/env bash

set -eo pipefail

# Install web dependencies if web directory exists and has mix.exs
if [ -f "web/mix.exs" ]; then
    echo "📦 Installing web dependencies..."
    (cd web && mix deps.get)

    if [ "$GITHUB_ACTIONS" != "true" ]; then
        echo "🗄️  Setting up database..."
        (cd web && mix ecto.setup)
    fi
fi

# Install CLI dependencies if cli directory exists and has go.mod
if [ -f "cli/go.mod" ]; then
    echo "📦 Installing CLI dependencies..."
    go mod download -C cli
fi

# Install docs dependencies if docs directory exists and has package.json
if [ -f "docs/package.json" ]; then
    echo "📦 Installing docs dependencies..."
    pnpm -C docs install
fi
