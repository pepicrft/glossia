defmodule Glossia.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    belongs_to :account, Glossia.Accounts.Account

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:account_id])
    |> validate_required([:account_id])
  end
end
