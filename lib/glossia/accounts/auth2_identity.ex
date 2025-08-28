defmodule Glossia.Accounts.Auth2Identity do
  @moduledoc false
  use Glossia.Schema

  alias Glossia.Accounts.User

  schema "auth2_identities" do
    field :provider, Ecto.Enum, values: [:github]
    field :user_id_on_provider, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(auth2_identity, attrs) do
    auth2_identity
    |> cast(attrs, [:provider, :user_id_on_provider, :user_id])
    |> validate_required([:provider, :user_id_on_provider, :user_id])
    |> unique_constraint([:provider, :user_id_on_provider])
    |> unique_constraint([:provider, :user_id])
  end

  def providers, do: [:github]
end
