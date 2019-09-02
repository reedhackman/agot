defmodule Agot.Repo do
  use Ecto.Repo,
    otp_app: :agot,
    adapter: Ecto.Adapters.Postgres
end
