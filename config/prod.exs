import Config

config :glossia, GlossiaWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

config :live_vue,
  ssr_module: LiveVue.SSR.NodeJS,
  ssr: true

# Do not print debug messages in production
config :logger, level: :info

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Glossia.Finch

# Disable Swoosh Local Memory Storage
# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
config :swoosh, local: false
