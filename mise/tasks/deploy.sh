#!/usr/bin/env bash
#MISE description="Deploys the application to Fly.io"

flyctl deploy --access-token "$FLY_API_TOKEN" --remote-only
