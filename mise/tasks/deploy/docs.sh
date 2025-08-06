#!/usr/bin/env bash
# mise description="Deploy documentation to Cloudflare Pages"

set -euo pipefail

echo "📦 Building documentation..."
pnpm -C docs install
pnpm -C docs exec vitepress build docs

echo "🚀 Deploying to Cloudflare Pages..."
cd docs/.vitepress/dist
wrangler pages deploy . --project-name=glossia-docs --compatibility-date=$(date +%Y-%m-%d)

echo "✅ Documentation deployed successfully!"