defmodule Glossia.Secrets do
  @moduledoc """
  Module for reading secrets and configuration from environment variables.
  """

  @doc """
  Gets the GitHub OAuth app credentials.
  """
  def github_oauth do
    %{
      client_id: get_env!("GITHUB_CLIENT_ID"),
      client_secret: get_env!("GITHUB_CLIENT_SECRET")
    }
  end

  @doc """
  Gets the GitLab OAuth app credentials.
  """
  def gitlab_oauth do
    %{
      client_id: get_env!("GITLAB_CLIENT_ID"),
      client_secret: get_env!("GITLAB_CLIENT_SECRET")
    }
  end

  @doc """
  Gets the GitHub App credentials for repository management.
  """
  def github_app do
    %{
      app_id: get_env!("GITHUB_APP_ID"),
      private_key: get_env!("GITHUB_APP_PRIVATE_KEY"),
      webhook_secret: get_env!("GITHUB_WEBHOOK_SECRET")
    }
  end

  @doc """
  Gets the base URL for the application.
  """
  def base_url do
    get_env("BASE_URL", "http://localhost:7070")
  end

  defp get_env!(key) do
    case System.get_env(key) do
      nil -> raise "Environment variable #{key} is not set"
      value -> value
    end
  end

  defp get_env(key, default) do
    System.get_env(key, default)
  end
end
