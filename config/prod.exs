use Mix.Config

config :loon, LoonWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: "loon-server.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE")

# Do not print debug messages in production
config :logger, level: :info
config :goth, json: {:system, "GCP_CREDENTIALS"}
