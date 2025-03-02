defmodule Glossia.Repo do
  use Ecto.Repo,
    otp_app: :glossia,
    adapter: Ecto.Adapters.Postgres
end
