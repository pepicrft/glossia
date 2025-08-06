#!/usr/bin/env bash
#MISE description="Deploys the web application to Fly.io"

cd web && flyctl deploy --access-token "$FLY_API_TOKEN" --remote-only
