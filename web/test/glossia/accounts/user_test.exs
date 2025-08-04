defmodule Glossia.Accounts.UserTest do
  use Glossia.DataCase

  alias Glossia.Accounts.{User, Account}

  @valid_attrs %{
    email: "test@example.com",
    account_id: "550e8400-e29b-41d4-a716-446655440000"
  }

  @invalid_attrs %{
    email: nil,
    account_id: nil
  }

  describe "changeset/2" do
    test "changeset with valid attributes" do
      changeset = User.changeset(%User{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = User.changeset(%User{}, @invalid_attrs)
      refute changeset.valid?
      assert errors_on(changeset).email
    end

    test "changeset requires email" do
      attrs = Map.put(@valid_attrs, :email, nil)
      changeset = User.changeset(%User{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset).email
    end

    test "changeset validates email format" do
      valid_emails = [
        "test@example.com",
        "user.name@example.com",
        "user+tag@example.com",
        "user@subdomain.example.com"
      ]

      for email <- valid_emails do
        attrs = Map.put(@valid_attrs, :email, email)
        changeset = User.changeset(%User{}, attrs)
        assert changeset.valid?, "Expected #{email} to be valid"
      end

      invalid_emails = [
        "invalid-email",
        "test@",
        "@example.com",
        ""
      ]

      for email <- invalid_emails do
        attrs = Map.put(@valid_attrs, :email, email)
        changeset = User.changeset(%User{}, attrs)
        refute changeset.valid?, "Expected #{email} to be invalid"
        assert errors_on(changeset).email
      end
    end

    test "changeset accepts nil account_id but doesn't require it for changeset validation" do
      # Note: Database constraint will enforce this, but changeset allows nil for flexibility
      attrs = Map.put(@valid_attrs, :account_id, nil)
      changeset = User.changeset(%User{}, attrs)
      assert changeset.valid?
    end
  end

  describe "database constraints" do
    setup do
      {:ok, account} = Repo.insert(%Account{handle: "testuser"})
      {:ok, account: account}
    end

    test "email must be unique", %{account: account} do
      # Create first user
      user1_attrs = %{email: "test@example.com", account_id: account.id}
      changeset1 = User.changeset(%User{}, user1_attrs)
      {:ok, _user1} = Repo.insert(changeset1)

      # Try to create second user with same email
      {:ok, account2} = Repo.insert(%Account{handle: "testuser2"})
      user2_attrs = %{email: "test@example.com", account_id: account2.id}
      changeset2 = User.changeset(%User{}, user2_attrs)

      assert {:error, changeset} = Repo.insert(changeset2)
      assert errors_on(changeset).email
    end

    test "can create user with valid data", %{account: account} do
      user_attrs = %{email: "valid@example.com", account_id: account.id}
      changeset = User.changeset(%User{}, user_attrs)

      assert {:ok, user} = Repo.insert(changeset)
      assert user.email == "valid@example.com"
      assert user.account_id == account.id
    end
  end
end
