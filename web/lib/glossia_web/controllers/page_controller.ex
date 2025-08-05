defmodule GlossiaWeb.PageController do
  use GlossiaWeb, :controller
  alias Glossia.{Blog, Changelog}

  def home(conn, _params) do
    recent_posts = Blog.recent_posts(3)
    recent_updates = Changelog.recent_entries(3)

    render(conn, :home,
      layout: false,
      recent_posts: recent_posts,
      recent_updates: recent_updates
    )
  end

  def dashboard(conn, %{"handle" => handle}) do
    # Load account by handle and verify user has access
    current_user = conn.assigns[:current_user]

    current_account =
      if current_user do
        Glossia.Repo.preload(current_user, :account).account
      else
        nil
      end

    render(conn, :dashboard,
      layout: {GlossiaWeb.Layouts, :app},
      current_user: current_user,
      current_account: current_account,
      handle: handle
    )
  end
end
