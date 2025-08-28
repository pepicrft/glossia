defmodule Glossia.Organizations.Organization do
  @moduledoc false
  use Glossia.Schema

  alias Glossia.Accounts.Account

  schema "organizations" do
    belongs_to :account, Account

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:account_id])
    |> validate_required([:account_id])
  end
end
