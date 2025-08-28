defmodule GlossiaWeb.CommitController do
  use GlossiaWeb, :controller

  plug :fetch_commit

  def show(%{assigns: %{selected_repository: selected_repository, commit: commit}} = conn, _params)
      when not is_nil(commit) do
    configuration =
      case Glossia.Repositories.configuration(commit[:sha], selected_repository) do
        {:ok, configuration} -> configuration
        {:error, _reason} -> nil
      end

    conn
    |> assign(
      :head_title,
      "#{commit[:message]} · #{commit[:short_sha]} - #{selected_repository.owner}/#{selected_repository.name}"
    )
    |> assign(
      :head_og_title,
      "#{commit[:message]} · #{commit[:short_sha]} - #{selected_repository.owner}/#{selected_repository.name}"
    )
    |> assign(
      :configuration,
      configuration
    )
    |> render(:show)
  end

  defp fetch_commit(%{assigns: %{selected_repository: _selected_repository}, params: %{"sha" => sha}} = conn, _opts) do
    {:ok, commits} = Glossia.Repositories.commits(conn.assigns.selected_repository)
    commit = commits |> Enum.find(&(&1[:sha] == sha))
    conn |> assign(:commit, commit)
  end
end
