defmodule GlossiaWeb.RepositoryController do
  use GlossiaWeb, :controller

  plug :fetch_configuration

  def show(%{assigns: %{selected_repository: selected_repository}} = conn, _params) do
    {:ok, commits} = Glossia.Repositories.commits(selected_repository)

    conn
    |> assign(:commits, commits)
    |> assign(:head_title, "#{selected_repository.owner}/#{selected_repository.name}")
    |> assign(:head_og_title, "#{selected_repository.owner}/#{selected_repository.name}")
    |> render(:show)
  end

  def settings(%{assigns: %{selected_repository: selected_repository}} = conn, _params) do
    conn
    |> assign(
      :head_title,
      "Repository - #{selected_repository.owner}/#{selected_repository.name}"
    )
    |> assign(
      :head_og_title,
      "Repository - #{selected_repository.owner}/#{selected_repository.name}"
    )
    |> render(:settings)
  end

  defp fetch_configuration(%{assigns: %{selected_repository: selected_repository}} = conn, _opts) do
    {:ok, configuration} = Glossia.Repositories.configuration(selected_repository)

    conn
    |> assign(:configuration, configuration)
  end
end
