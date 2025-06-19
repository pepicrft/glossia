defmodule Glossia.Formatters.String do
  @moduledoc false
  @doc ~S"""
  Enumerates a list of strings.

  ## Parameters

  - `strings` - The list of strings to enumerate.

  ## Returns

  - `String.t()` - The enumerated string.

  ## Example

  > iex> Glossia.Formatters.String.enumerate(["one", "two", "three"])
  "one, two and three"
  """
  def enumerate(strings) when is_list(strings) do
    case length(strings) do
      0 ->
        ""

      1 ->
        hd(strings)

      2 ->
        Enum.join(strings, " and ")

      _ ->
        Enum.join(Enum.take(strings, length(strings) - 1), ", ") <> " and " <> List.last(strings)
    end
  end
end
