defmodule GlossiaWeb.InfoController do
  @moduledoc """
  Controller for info pages like About and Terms of Service.
  """

  use GlossiaWeb, :controller

  def about(conn, _params) do
    render(conn, :about, page_title: "About")
  end

  def terms(conn, _params) do
    render(conn, :terms, page_title: "Terms of Service")
  end

  def cookies(conn, _params) do
    render(conn, :cookies, page_title: "Cookie Policy")
  end
end
