# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20241202-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.17.3-erlang-27.1.2-debian-bullseye-20241202-slim
#
ARG VERSION
ARG ELIXIR_VERSION=1.18.4
ARG OTP_VERSION=28.0.2
ARG DEBIAN_VERSION=bullseye-20250721-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

# Build daemon stage
FROM ${BUILDER_IMAGE} as daemon_builder

# install build dependencies for daemon
RUN apt-get update -y && apt-get install -y build-essential git curl unzip \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Install Zig for Burrito cross-compilation (version 0.14.1 required by Burrito 1.4.0)
RUN curl -L https://ziglang.org/download/0.14.1/zig-x86_64-linux-0.14.1.tar.xz | tar -xJ && \
    mv zig-x86_64-linux-0.14.1 /opt/zig && \
    ln -s /opt/zig/zig /usr/local/bin/zig

WORKDIR /daemon

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy daemon source
COPY daemon/mix.exs daemon/mix.lock ./
RUN MIX_ENV=prod mix deps.get
COPY daemon/lib lib

# Build daemon release for Linux
RUN MIX_ENV=prod BURRITO_TARGET=linux_x86_64 mix release

# Package daemon binary as tar.gz
RUN cd burrito_out && \
    tar -czf glossia_daemon_linux_x86_64.tar.gz glossia_daemon_linux_x86_64

# Web app builder stage
FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY web/mix.exs web/mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY web/config/config.exs web/config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY web/priv priv

COPY web/lib lib

COPY web/assets assets

# Copy daemon binary from daemon_builder stage to static assets
COPY --from=daemon_builder /daemon/burrito_out/glossia_daemon_linux_x86_64.tar.gz priv/static/bin/daemon.tar.gz

# compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY web/config/runtime.exs config/

COPY web/rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && \
    apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/glossia ./

USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
# ENTRYPOINT ["/tini", "--"]

CMD ["/app/bin/server"]