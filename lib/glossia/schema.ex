defmodule Glossia.Schema do
  @moduledoc """
  Base schema module that configures UUIDv7 as the primary key type for all schemas.
  """

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset

      @primary_key {:id, UUIDv7, autogenerate: true}
      @foreign_key_type UUIDv7
      @timestamps_opts [type: :utc_datetime]
    end
  end
end
