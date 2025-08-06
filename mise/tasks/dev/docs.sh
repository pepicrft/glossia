#!/usr/bin/env bash
# mise description="Dev the documentation"

set -eo pipefail

pnpm -C docs exec vitepress dev
