defmodule GlossiaWeb.AuthControllerTest do
  use GlossiaWeb.ConnCase

  alias Glossia.Accounts

  describe "GET /auth/:provider" do
    test "redirects to GitHub OAuth", %{conn: conn} do
      conn = get(conn, ~p"/auth/github")
      
      assert redirected_to(conn) =~ "github.com/login/oauth/authorize"
    end

    test "includes client_id in redirect URL", %{conn: conn} do
      conn = get(conn, ~p"/auth/github")
      
      location = redirected_to(conn)
      assert location =~ "client_id="
    end
  end

  describe "authentication logic" do
    test "creates new user with GitHub authentication data" do
      # Verify user doesn't exist
      refute Accounts.get_user_by_auth(:github, "12345")

      # Create user through authentication
      {:ok, user} = Accounts.find_or_create_user_by_auth(:github, "12345", "testuser@example.com")

      assert user.email == "testuser@example.com"
      assert user.account.handle == "testuser"
      
      # Verify auth identity was created
      auth_identity = List.first(user.auth2_identities)
      assert auth_identity.provider == :github
      assert auth_identity.user_id_on_provider == "12345"
    end

    test "returns existing user for same authentication data" do
      # Create initial user
      {:ok, user1} = Accounts.find_or_create_user_by_auth(:github, "12345", "testuser@example.com")

      # Try to authenticate again
      {:ok, user2} = Accounts.find_or_create_user_by_auth(:github, "12345", "testuser@example.com")

      assert user1.id == user2.id
    end

    test "handles complex email addresses in handle generation" do
      {:ok, user} = Accounts.find_or_create_user_by_auth(:github, "12345", "user.name+tag@example.com")
      assert user.account.handle == "usernametag"
    end

    test "handles duplicate handles by adding suffix" do
      # Create first user
      {:ok, user1} = Accounts.find_or_create_user_by_auth(:github, "11111", "test@example.com")
      assert user1.account.handle == "test"

      # Create second user with same email domain
      {:ok, user2} = Accounts.find_or_create_user_by_auth(:github, "22222", "test@different.com")
      assert user2.account.handle == "test1"
    end
  end

  describe "POST /auth/logout" do
    test "logs out user and clears session", %{conn: conn} do
      # First, create and log in a user
      {:ok, user} = Accounts.find_or_create_user_by_auth(:github, "12345", "test@example.com")
      
      conn = 
        conn
        |> init_test_session(%{})
        |> put_session(:user_id, user.id)
        |> post(~p"/auth/logout")

      assert redirected_to(conn) == "/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "Logged out successfully"
      refute get_session(conn, :user_id)
    end

    test "handles logout when not logged in", %{conn: conn} do
      conn = 
        conn
        |> init_test_session(%{})
        |> post(~p"/auth/logout")

      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_id)
    end
  end

end