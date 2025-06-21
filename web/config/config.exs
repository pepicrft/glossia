# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  glossia: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    # When :glossia is used as a dependency, it's part of a /deps directory, therefore we need
    # to include the directory that contains :glossia in NODE_PATH.
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__) <> ":" <> Path.expand("../..", __DIR__)}
  ]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :glossia, Glossia.Mailer, adapter: Swoosh.Adapters.Local

# Configures the endpoint
config :glossia, GlossiaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: GlossiaWeb.ErrorHTML, json: GlossiaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Glossia.PubSub,
  live_view: [signing_salt: "bIht7Dkg"]

config :glossia,
  ecto_repos: [Glossia.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Tailwind
config :tailwind,
  version: "4.0.0",
  glossia: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configure Ueberauth
config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, []}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
