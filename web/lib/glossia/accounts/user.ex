defmodule Glossia.Accounts.User do
  @moduledoc false
  use Glossia.Schema

  schema "users" do
    field :email, :string

    belongs_to :account, Glossia.Accounts.Account
    has_many :auth2_identities, Glossia.Accounts.Auth2Identity

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :account_id])
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> unique_constraint(:email)
  end
end
