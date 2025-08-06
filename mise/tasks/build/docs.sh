#!/usr/bin/env bash
# mise description="Build the documentation"

set -eo pipefail

pnpm -C docs install
pnpm -C docs exec vitepress build
