defmodule GlossiaWeb.Plugs.Auth do
  @moduledoc """
  Authentication plug that loads the current user from the session.
  """

  import Plug.Conn

  alias Glossia.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    current_user = user_id && Accounts.get_user(user_id)
    assign(conn, :current_user, current_user)
  end
end
