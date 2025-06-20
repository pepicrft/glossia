defmodule Glossia.Repo.Migrations.CreateAuth2Identities do
  use Ecto.Migration

  def change do
    execute "CREATE TYPE provider_enum AS ENUM ('github', 'gitlab')",
            "DROP TYPE provider_enum"

    create table(:auth2_identities) do
      add :provider, :provider_enum, null: false
      add :user_id_on_provider, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:auth2_identities, [:provider, :user_id_on_provider])
    create unique_index(:auth2_identities, [:provider, :user_id])
    create index(:auth2_identities, [:user_id])
  end
end
