defmodule Glossia.Accounts.AccountTest do
  use Glossia.DataCase

  alias Glossia.Accounts.Account

  @valid_attrs %{handle: "testuser"}
  @invalid_attrs %{handle: nil}

  describe "changeset/2" do
    test "changeset with valid attributes" do
      changeset = Account.changeset(%Account{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Account.changeset(%Account{}, @invalid_attrs)
      refute changeset.valid?
      assert errors_on(changeset).handle
    end

    test "changeset requires handle" do
      changeset = Account.changeset(%Account{}, %{handle: nil})
      refute changeset.valid?
      assert errors_on(changeset).handle
    end

    test "changeset validates handle length" do
      # Too short
      changeset = Account.changeset(%Account{}, %{handle: ""})
      refute changeset.valid?
      assert errors_on(changeset).handle

      # Valid length
      changeset = Account.changeset(%Account{}, %{handle: "a"})
      assert changeset.valid?

      changeset = Account.changeset(%Account{}, %{handle: String.duplicate("a", 100)})
      assert changeset.valid?

      # Too long
      changeset = Account.changeset(%Account{}, %{handle: String.duplicate("a", 101)})
      refute changeset.valid?
      assert errors_on(changeset).handle
    end

    test "changeset validates handle format" do
      valid_handles = [
        "user",
        "user123",
        "user_name",
        "user-name",
        "123user",
        "a",
        "User123"
      ]

      for handle <- valid_handles do
        changeset = Account.changeset(%Account{}, %{handle: handle})
        assert changeset.valid?, "Expected #{handle} to be valid"
      end

      invalid_handles = [
        "user.name",
        "user name",
        "user@name",
        "user#name",
        "user+name",
        "user!name"
      ]

      for handle <- invalid_handles do
        changeset = Account.changeset(%Account{}, %{handle: handle})
        refute changeset.valid?, "Expected #{handle} to be invalid"
        assert errors_on(changeset).handle
      end
    end
  end

  describe "database constraints" do
    test "handle must be unique" do
      # Create first account
      changeset1 = Account.changeset(%Account{}, %{handle: "testuser"})
      {:ok, _account1} = Repo.insert(changeset1)

      # Try to create second account with same handle
      changeset2 = Account.changeset(%Account{}, %{handle: "testuser"})
      assert {:error, changeset} = Repo.insert(changeset2)
      assert errors_on(changeset).handle
    end

    test "can create account with valid data" do
      changeset = Account.changeset(%Account{}, %{handle: "validuser"})
      assert {:ok, account} = Repo.insert(changeset)
      assert account.handle == "validuser"
    end

    test "different handles can coexist" do
      changeset1 = Account.changeset(%Account{}, %{handle: "user1"})
      changeset2 = Account.changeset(%Account{}, %{handle: "user2"})
      
      {:ok, account1} = Repo.insert(changeset1)
      {:ok, account2} = Repo.insert(changeset2)
      
      assert account1.handle == "user1"
      assert account2.handle == "user2"
    end
  end

end