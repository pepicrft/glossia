defmodule Glossia.Accounts.Account do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :handle, :string

    has_many :users, Glossia.Accounts.User
    has_many :organizations, Glossia.Organizations.Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:handle])
    |> validate_required([:handle])
    |> validate_length(:handle, min: 1, max: 100)
    |> validate_format(:handle, ~r/^[a-zA-Z0-9_-]+$/,
      message: "must contain only letters, numbers, underscores and hyphens"
    )
    |> unique_constraint(:handle)
  end
end
