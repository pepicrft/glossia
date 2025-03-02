#!/usr/bin/env bash

set -eo pipefail

mix deps.get
mix ecto.setup
