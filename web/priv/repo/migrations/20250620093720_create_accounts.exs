defmodule Glossia.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :handle, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:accounts, [:handle])
  end
end
