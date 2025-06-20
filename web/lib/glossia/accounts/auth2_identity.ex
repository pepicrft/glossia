defmodule Glossia.Accounts.Auth2Identity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "auth2_identities" do
    field :provider, Ecto.Enum, values: [:github, :gitlab]
    field :user_id_on_provider, :string

    belongs_to :user, Glossia.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(auth2_identity, attrs) do
    auth2_identity
    |> cast(attrs, [:provider, :user_id_on_provider, :user_id])
    |> validate_required([:provider, :user_id_on_provider, :user_id])
    |> unique_constraint([:provider, :user_id_on_provider])
    |> unique_constraint([:provider, :user_id])
  end

  def providers, do: [:github, :gitlab]
end