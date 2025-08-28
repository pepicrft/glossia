defmodule Glossia.Changelog.Entry do
  @moduledoc """
  Struct representing a changelog entry.
  """

  @enforce_keys [:id, :title, :body, :date, :published, :type]
  defstruct [:id, :title, :body, :date, :published, :type]

  def build(filename, attrs, body) do
    [year, month_day_id] = filename |> Path.rootname() |> Path.split() |> Enum.take(-2)
    [month, day, id] = String.split(month_day_id, "-", parts: 3)
    date = Date.from_iso8601!("#{year}-#{month}-#{day}")

    struct!(
      __MODULE__,
      [
        id: id,
        date: date,
        body: body,
        published: Map.get(attrs, :published, true),
        type: Map.get(attrs, :type, :update)
      ] ++ Map.to_list(attrs)
    )
  end
end
