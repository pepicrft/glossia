defmodule Glossia.Fixtures do
  @moduledoc """
  Test fixtures for creating test data.
  """

  alias Glossia.Repo
  alias Glossia.Accounts.{Account, User, Auth2Identity}

  @doc """
  Creates an account with the given attributes.
  """
  def account_fixture(attrs \\ %{}) do
    attrs = 
      attrs
      |> Enum.into(%{handle: "testuser#{System.unique_integer([:positive])}"})

    {:ok, account} = 
      %Account{}
      |> Account.changeset(attrs)
      |> Repo.insert()

    account
  end

  @doc """
  Creates a user with the given attributes.
  """
  def user_fixture(attrs \\ %{}) do
    account = attrs[:account] || account_fixture()
    
    attrs = 
      attrs
      |> Enum.into(%{
        email: "user#{System.unique_integer([:positive])}@example.com",
        account_id: account.id
      })
      |> Map.drop([:account])

    {:ok, user} = 
      %User{}
      |> User.changeset(attrs)
      |> Repo.insert()

    user |> Repo.preload([:account, :auth2_identities])
  end

  @doc """
  Creates an auth2_identity with the given attributes.
  """
  def auth2_identity_fixture(attrs \\ %{}) do
    user = attrs[:user] || user_fixture()
    
    attrs = 
      attrs
      |> Enum.into(%{
        provider: 0,  # github
        user_id_on_provider: "#{System.unique_integer([:positive])}",
        user_id: user.id
      })
      |> Map.drop([:user])

    {:ok, auth2_identity} = 
      %Auth2Identity{}
      |> Auth2Identity.changeset(attrs)
      |> Repo.insert()

    auth2_identity |> Repo.preload(:user)
  end

  @doc """
  Creates a complete user with account and auth2_identity.
  """
  def complete_user_fixture(attrs \\ %{}) do
    account_attrs = Map.get(attrs, :account, %{})
    user_attrs = Map.get(attrs, :user, %{})
    auth_attrs = Map.get(attrs, :auth2_identity, %{})

    account = account_fixture(account_attrs)
    user = user_fixture(Map.put(user_attrs, :account, account))
    _auth2_identity = auth2_identity_fixture(Map.put(auth_attrs, :user, user))

    user |> Repo.preload([:account, :auth2_identities])
  end

  @doc """
  Creates a mock Ueberauth.Auth struct for testing.
  """
  def ueberauth_auth_fixture(attrs \\ %{}) do
    attrs = 
      attrs
      |> Enum.into(%{
        uid: System.unique_integer([:positive]),
        provider: :github,
        info: %{
          email: "test#{System.unique_integer([:positive])}@example.com",
          name: "Test User"
        }
      })

    %Ueberauth.Auth{
      uid: attrs.uid,
      provider: attrs.provider,
      info: %Ueberauth.Auth.Info{
        email: attrs.info.email,
        name: attrs.info.name
      }
    }
  end

  @doc """
  Creates a mock Ueberauth.Failure struct for testing.
  """
  def ueberauth_failure_fixture(attrs \\ %{}) do
    attrs = 
      attrs
      |> Enum.into(%{
        provider: :github,
        errors: [%Ueberauth.Failure.Error{message: "OAuth failed"}]
      })

    %Ueberauth.Failure{
      provider: attrs.provider,
      errors: attrs.errors
    }
  end
end