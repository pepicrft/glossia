defmodule GlossiaWeb.ChangelogController do
  use GlossiaWeb, :controller
  alias Glossia.Changelog

  def index(conn, _params) do
    entries = Changelog.published_entries()

    render(conn, :index,
      entries: entries,
      page_title: "Changelog",
      layout: {GlossiaWeb.Layouts, :app}
    )
  end

  def show(conn, %{"id" => id}) do
    entry = Changelog.get_entry_by_id!(id)
    render(conn, :show, entry: entry, page_title: entry.title, layout: {GlossiaWeb.Layouts, :app})
  end

  def feed(conn, %{"format" => format}) when format in ["rss", "atom"] do
    entries = Changelog.recent_entries(50)
    
    template_path = Path.join([
      __DIR__, 
      "changelog_html", 
      "feed_#{format}.xml.eex"
    ])
    
    xml_content = EEx.eval_file(template_path, 
      assigns: %{
        entries: entries, 
        conn: conn, 
        url: fn path -> Phoenix.VerifiedRoutes.unverified_url(conn, path) end
      }
    )

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, xml_content)
  end
end
