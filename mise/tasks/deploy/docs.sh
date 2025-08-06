#!/usr/bin/env bash
# mise description="Deploy documentation to Cloudflare Pages"

set -euo pipefail

echo "📦 Building documentation..."
pnpm -C docs exec vitepress build

echo "🚀 Deploying to Cloudflare Pages..."
cd docs/.vitepress/dist
wrangler pages deploy . --project-name=glossia-docs

echo "✅ Documentation deployed successfully!"
