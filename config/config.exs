# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :agot,
  ecto_repos: [Agot.Repo]

# Configures the endpoint
config :agot, AgotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CB4Q92+H7Q9g5DEXDnaEw0ltlECU10u4k/0HO3eby9qiqq2qb+kIJWRa9dKGDXyL",
  render_errors: [view: AgotWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Agot.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
