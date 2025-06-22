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
end
