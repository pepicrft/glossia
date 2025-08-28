defmodule GlossiaWeb.BlogController do
  use GlossiaWeb, :controller

  alias Glossia.Blog

  def feed(conn, %{"format" => format}) when format in ["rss", "atom"] do
    posts = Blog.recent_posts(20)

    template_path =
      Path.join([
        __DIR__,
        "blog_html",
        "feed_#{format}.xml.eex"
      ])

    xml_content =
      EEx.eval_file(template_path,
        assigns: %{
          posts: posts,
          conn: conn,
          url: fn path -> Phoenix.VerifiedRoutes.unverified_url(conn, path) end
        }
      )

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, xml_content)
  end
end
