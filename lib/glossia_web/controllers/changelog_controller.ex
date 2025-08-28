defmodule GlossiaWeb.ChangelogController do
  use GlossiaWeb, :controller

  alias Glossia.Changelog

  def feed(conn, %{"format" => format}) when format in ["rss", "atom"] do
    entries = Changelog.recent_entries(50)

    template_path =
      Path.join([
        __DIR__,
        "changelog_html",
        "feed_#{format}.xml.eex"
      ])

    xml_content =
      EEx.eval_file(template_path,
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
