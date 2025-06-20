defmodule Glossia.Accounts.Auth2Identity do
  use Ecto.Schema
  import Ecto.Changeset

  @providers %{github: 0, gitlab: 1}

  schema "auth2_identities" do
    field :provider, :integer
    field :user_id_on_provider, :string

    belongs_to :user, Glossia.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(auth2_identity, attrs) do
    auth2_identity
    |> cast(attrs, [:provider, :user_id_on_provider, :user_id])
    |> validate_required([:provider, :user_id_on_provider, :user_id])
    |> validate_inclusion(:provider, Map.values(@providers))
    |> unique_constraint([:provider, :user_id_on_provider])
    |> unique_constraint([:provider, :user_id])
  end

  def providers, do: @providers
end