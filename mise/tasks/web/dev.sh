#!/usr/bin/env bash
# mise description="Dev the web project"

set -eo pipefail

cd web && mix phx.server
