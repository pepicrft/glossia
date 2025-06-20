defmodule Glossia.Accounts.Auth2IdentityTest do
  use Glossia.DataCase

  alias Glossia.Accounts.Auth2Identity

  @valid_attrs %{
    provider: :github,
    user_id_on_provider: "12345",
    user_id: 1
  }

  @invalid_attrs %{
    provider: nil,
    user_id_on_provider: nil,
    user_id: nil
  }

  describe "changeset/2" do
    test "changeset with valid attributes" do
      changeset = Auth2Identity.changeset(%Auth2Identity{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Auth2Identity.changeset(%Auth2Identity{}, @invalid_attrs)
      refute changeset.valid?
      assert errors_on(changeset).provider
      assert errors_on(changeset).user_id_on_provider
      assert errors_on(changeset).user_id
    end

    test "changeset requires provider" do
      attrs = Map.put(@valid_attrs, :provider, nil)
      changeset = Auth2Identity.changeset(%Auth2Identity{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset).provider
    end

    test "changeset requires user_id_on_provider" do
      attrs = Map.put(@valid_attrs, :user_id_on_provider, nil)
      changeset = Auth2Identity.changeset(%Auth2Identity{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset).user_id_on_provider
    end

    test "changeset requires user_id" do
      attrs = Map.put(@valid_attrs, :user_id, nil)
      changeset = Auth2Identity.changeset(%Auth2Identity{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset).user_id
    end

    test "changeset validates provider is in valid range" do
      # Valid providers: :github, :gitlab
      valid_changeset = Auth2Identity.changeset(%Auth2Identity{}, Map.put(@valid_attrs, :provider, :gitlab))
      assert valid_changeset.valid?

      invalid_changeset = Auth2Identity.changeset(%Auth2Identity{}, Map.put(@valid_attrs, :provider, :invalid))
      refute invalid_changeset.valid?
      assert errors_on(invalid_changeset).provider
    end

    test "changeset accepts string user_id_on_provider" do
      changeset = Auth2Identity.changeset(%Auth2Identity{}, @valid_attrs)
      assert changeset.valid?
      assert get_change(changeset, :user_id_on_provider) == "12345"
    end
  end

  describe "providers/0" do
    test "returns provider list" do
      providers = Auth2Identity.providers()
      assert :github in providers
      assert :gitlab in providers
    end
  end

end