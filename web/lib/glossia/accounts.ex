defmodule Glossia.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Glossia.Repo

  alias Glossia.Accounts.{Account, User, Auth2Identity}

  @doc """
  Finds or creates a user based on OAuth authentication information.
  """
  def find_or_create_user_by_auth(provider, user_id_on_provider, email) do
    case get_user_by_auth(provider, user_id_on_provider) do
      nil -> create_user_with_auth(provider, user_id_on_provider, email)
      user -> {:ok, user}
    end
  end

  @doc """
  Gets a user by authentication provider and provider user ID.
  """
  def get_user_by_auth(provider, user_id_on_provider) do
    from(u in User,
      join: ai in assoc(u, :auth2_identities),
      where: ai.provider == ^provider and ai.user_id_on_provider == ^user_id_on_provider,
      preload: [:account, :auth2_identities]
    )
    |> Repo.one()
  end

  @doc """
  Gets a user by ID.
  """
  def get_user(id) do
    Repo.get(User, id)
    |> Repo.preload([:account, :auth2_identities])
  end

  defp create_user_with_auth(provider, user_id_on_provider, email) do
    Repo.transaction(fn ->
      # Create account with handle derived from email
      handle = generate_handle_from_email(email)
      
      with {:ok, account} <- create_account(handle),
           {:ok, user} <- create_user(email, account.id),
           {:ok, _auth_identity} <- create_auth2_identity(provider, user_id_on_provider, user.id) do
        user |> Repo.preload([:account, :auth2_identities])
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  @doc """
  Creates an account.
  """
  def create_account(handle) do
    %Account{}
    |> Account.changeset(%{handle: handle})
    |> Repo.insert()
  end

  @doc """
  Creates a user.
  """
  def create_user(email, account_id) do
    %User{}
    |> User.changeset(%{email: email, account_id: account_id})
    |> Repo.insert()
  end

  @doc """
  Creates an Auth2Identity.
  """
  def create_auth2_identity(provider, user_id_on_provider, user_id) do
    %Auth2Identity{}
    |> Auth2Identity.changeset(%{
      provider: provider,
      user_id_on_provider: user_id_on_provider,
      user_id: user_id
    })
    |> Repo.insert()
  end

  defp generate_handle_from_email(email) do
    email
    |> String.split("@")
    |> List.first()
    |> String.replace(~r/[^a-zA-Z0-9_-]/, "")
    |> String.downcase()
    |> ensure_unique_handle()
  end

  defp ensure_unique_handle(base_handle) do
    case get_account_by_handle(base_handle) do
      nil -> base_handle
      _account -> find_unique_handle(base_handle, 1)
    end
  end

  defp find_unique_handle(base_handle, suffix) do
    candidate = "#{base_handle}#{suffix}"
    case get_account_by_handle(candidate) do
      nil -> candidate
      _account -> find_unique_handle(base_handle, suffix + 1)
    end
  end

  @doc """
  Gets an account by handle.
  """
  def get_account_by_handle(handle) do
    Repo.get_by(Account, handle: handle)
  end
end