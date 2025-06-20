defmodule Glossia.AccountsTest do
  use Glossia.DataCase

  alias Glossia.Accounts
  alias Glossia.Accounts.{Account, User, Auth2Identity}

  describe "accounts" do
    test "create_account/1 with valid data creates an account" do
      valid_attrs = %{handle: "testuser"}

      assert {:ok, %Account{} = account} = Accounts.create_account(valid_attrs.handle)
      assert account.handle == "testuser"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account("")
    end

    test "create_account/1 with duplicate handle returns error changeset" do
      {:ok, _account} = Accounts.create_account("testuser")
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account("testuser")
    end

    test "get_account_by_handle/1 returns the account with given handle" do
      {:ok, account} = Accounts.create_account("testuser")
      assert Accounts.get_account_by_handle("testuser").id == account.id
    end

    test "get_account_by_handle/1 returns nil when account doesn't exist" do
      assert Accounts.get_account_by_handle("nonexistent") == nil
    end
  end

  describe "users" do
    test "create_user/2 with valid data creates a user" do
      {:ok, account} = Accounts.create_account("testuser")
      email = "test@example.com"

      assert {:ok, %User{} = user} = Accounts.create_user(email, account.id)
      assert user.email == email
      assert user.account_id == account.id
    end

    test "create_user/2 with invalid email returns error changeset" do
      {:ok, account} = Accounts.create_account("testuser")
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user("invalid-email", account.id)
    end

    test "create_user/2 with duplicate email returns error changeset" do
      {:ok, account} = Accounts.create_account("testuser")
      email = "test@example.com"
      {:ok, _user} = Accounts.create_user(email, account.id)

      {:ok, account2} = Accounts.create_account("testuser2")
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(email, account2.id)
    end

    test "get_user/1 returns the user with given id" do
      {:ok, account} = Accounts.create_account("testuser")
      {:ok, user} = Accounts.create_user("test@example.com", account.id)

      fetched_user = Accounts.get_user(user.id)
      assert fetched_user.id == user.id
      assert fetched_user.account.handle == "testuser"
    end
  end

  describe "auth2_identities" do
    test "create_auth2_identity/3 with valid data creates an auth2_identity" do
      {:ok, account} = Accounts.create_account("testuser")
      {:ok, user} = Accounts.create_user("test@example.com", account.id)

      provider = :github
      user_id_on_provider = "12345"

      assert {:ok, %Auth2Identity{} = auth_identity} =
               Accounts.create_auth2_identity(provider, user_id_on_provider, user.id)

      assert auth_identity.provider == provider
      assert auth_identity.user_id_on_provider == user_id_on_provider
      assert auth_identity.user_id == user.id
    end

    test "create_auth2_identity/3 with duplicate provider and user_id_on_provider returns error" do
      {:ok, account} = Accounts.create_account("testuser")
      {:ok, user} = Accounts.create_user("test@example.com", account.id)

      provider = :github
      user_id_on_provider = "12345"

      {:ok, _auth_identity} =
        Accounts.create_auth2_identity(provider, user_id_on_provider, user.id)

      {:ok, account2} = Accounts.create_account("testuser2")
      {:ok, user2} = Accounts.create_user("test2@example.com", account2.id)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_auth2_identity(provider, user_id_on_provider, user2.id)
    end

    test "get_user_by_auth/2 returns user with given provider and user_id_on_provider" do
      {:ok, account} = Accounts.create_account("testuser")
      {:ok, user} = Accounts.create_user("test@example.com", account.id)
      {:ok, _auth_identity} = Accounts.create_auth2_identity(:github, "12345", user.id)

      fetched_user = Accounts.get_user_by_auth(:github, "12345")
      assert fetched_user.id == user.id
      assert fetched_user.account.handle == "testuser"
      assert length(fetched_user.auth2_identities) == 1
    end

    test "get_user_by_auth/2 returns nil when no matching auth identity exists" do
      assert Accounts.get_user_by_auth(:github, "nonexistent") == nil
    end
  end

  describe "find_or_create_user_by_auth/3" do
    test "creates new user when no existing auth identity found" do
      user_id = UUIDv7.generate()
      email = "#{user_id}@example.com"

      assert {:ok, user} = Accounts.find_or_create_user_by_auth(:github, "12345", email)
      assert user.email == email
      assert user.account.handle == user_id
      assert length(user.auth2_identities) == 1

      auth_identity = List.first(user.auth2_identities)
      assert auth_identity.provider == :github
      assert auth_identity.user_id_on_provider == "12345"
    end

    test "returns existing user when auth identity already exists" do
      email = "#{UUIDv7.generate()}@example.com"
      provider_user_id = UUIDv7.generate()

      # Create initial user
      {:ok, user1} = Accounts.find_or_create_user_by_auth(:github, provider_user_id, email)

      # Try to create again with same auth info
      {:ok, user2} = Accounts.find_or_create_user_by_auth(:github, provider_user_id, email)

      assert user1.id == user2.id
    end

    test "generates unique handle when email domain conflicts" do
      base_handle = UUIDv7.generate()

      # Create first user with handle
      {:ok, user1} =
        Accounts.find_or_create_user_by_auth(
          :github,
          UUIDv7.generate(),
          "#{base_handle}@example.com"
        )

      assert user1.account.handle == base_handle

      # Create second user with same email domain
      {:ok, user2} =
        Accounts.find_or_create_user_by_auth(
          :github,
          UUIDv7.generate(),
          "#{base_handle}@different.com"
        )

      assert user2.account.handle == "#{base_handle}1"

      # Create third user with same email domain
      {:ok, user3} =
        Accounts.find_or_create_user_by_auth(
          :github,
          UUIDv7.generate(),
          "#{base_handle}@another.com"
        )

      assert user3.account.handle == "#{base_handle}2"
    end

    test "handles complex email addresses" do
      {:ok, user} =
        Accounts.find_or_create_user_by_auth(
          :github,
          UUIDv7.generate(),
          "user.name+tag@example.com"
        )

      assert user.account.handle == "usernametag"
    end

    test "handles email with special characters" do
      {:ok, user} =
        Accounts.find_or_create_user_by_auth(:github, UUIDv7.generate(), "user-name@example.com")

      assert user.account.handle == "user-name"
    end
  end
end
