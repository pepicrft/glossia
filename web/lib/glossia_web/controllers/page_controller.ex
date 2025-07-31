defmodule GlossiaWeb.PageController do
  use GlossiaWeb, :controller
  alias Glossia.{Blog, Changelog}

  def home(conn, _params) do
    recent_posts = Blog.recent_posts(3)
    recent_updates = Changelog.recent_entries(3)

    render(conn, :home,
      recent_posts: recent_posts,
      recent_updates: recent_updates,
      layout: {GlossiaWeb.Layouts, :app}
    )
  end

  def dashboard(conn, %{"handle" => handle}) do
    # TODO: Load account by handle and verify user has access
    # For now, just render the dashboard
    current_user = conn.assigns[:current_user]
    current_account = if current_user do
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
