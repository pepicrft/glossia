defmodule Glossia.Changelog do
  @moduledoc """
  Changelog entry management using Nimble Publisher.
  """

  use NimblePublisher,
    build: Glossia.Changelog.Entry,
    from: Application.app_dir(:glossia, "priv/changelog/**/*.md"),
    as: :entries,
    highlighters: []

  @entries Enum.sort_by(@entries, & &1.date, {:desc, Date})

  def all_entries, do: @entries
  def published_entries, do: Enum.filter(@entries, & &1.published)

  def get_entry_by_id!(id) do
    Enum.find(all_entries(), &(&1.id == id)) || raise Glossia.Changelog.NotFoundError
  end

  def recent_entries(count \\ 10) do
    published_entries()
    |> Enum.take(count)
  end

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end
end
