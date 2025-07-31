defmodule GlossiaWeb.AuthController do
  use GlossiaWeb, :controller
  plug Ueberauth

  alias Glossia.Accounts

  def login(conn, _params) do
    render(conn, :login)
  end

  def request(conn, _params) do
    # This function is handled by Ueberauth automatically
    # It redirects to the OAuth provider
    conn
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Authentication failed")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"provider" => provider}) do
    case create_or_update_user(auth, provider) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Successfully authenticated!")
        |> redirect(to: ~p"/dashboard")

      {:error, reason} ->
        conn
        |> put_flash(:error, "Authentication failed: #{reason}")
        |> redirect(to: ~p"/")
    end
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "Authentication failed")
    |> redirect(to: ~p"/")
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Logged out successfully")
    |> redirect(to: ~p"/")
  end

  defp create_or_update_user(auth, provider) do
    provider_atom = provider_string_to_atom(provider)
    user_id_on_provider = Integer.to_string(auth.uid)
    email = auth.info.email

    if provider_atom && email do
      case Accounts.find_or_create_user_by_auth(provider_atom, user_id_on_provider, email) do
        {:ok, user} -> {:ok, user}
        {:error, changeset} -> {:error, inspect(changeset.errors)}
      end
    else
      {:error, "Invalid provider or missing email"}
    end
  end

  defp provider_string_to_atom("github"), do: :github
  defp provider_string_to_atom(_), do: nil
end
