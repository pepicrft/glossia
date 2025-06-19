defmodule Glossia.Environment do
  @moduledoc ~S"""
  Glossia is configured at runtime using environment variables. This module provides an interface to read and validate the configuration.
  All the configuration env. variables are scoped under the `GLOSSIA_` prefix.
  """

  @email_adapter_env_var "GLOSSIA_EMAIL_ADAPTER"
  @email_smtp_relay_env_var "GLOSSIA_EMAIL_SMTP_RELAY"
  @email_smtp_username_env_var "GLOSSIA_EMAIL_SMTP_USERNAME"
  @email_smtp_password_env_var "GLOSSIA_EMAIL_SMTP_PASSWORD"
  @email_smtp_port_env_var "GLOSSIA_EMAIL_SMTP_PORT"
  @email_smtp_retries_env_var "GLOSSIA_EMAIL_SMTP_RETRIES"
  @email_smtp_no_mx_lookups_env_var "GLOSSIA_EMAIL_SMTP_NO_MX_LOOKUPS"
  @email_smtp_auth_env_var "GLOSSIA_EMAIL_SMTP_AUTH"
  @email_smtp_ssl_env_var "GLOSSIA_EMAIL_SMTP_SSL"
  @email_smtp_tls_env_var "GLOSSIA_EMAIL_SMTP_TLS"
  @email_smtp_required_vars [
    @email_smtp_relay_env_var,
    @email_smtp_username_env_var,
    @email_smtp_password_env_var,
    @email_smtp_port_env_var
  ]

  @doc ~S"""
  Returns the email adapter to use.

  ## Parameters

  - `env` - The environment variables to use. Defaults to `System.get_env()`.

  ## Returns

  - `:smtp` - The SMTP adapter.

  ## Raises

  - `RuntimeError` if the email adapter is invalid.
  """
  def email_adapter(env \\ System.get_env()) do
    case Map.get(env, @email_adapter_env_var) do
      "smtp" -> :smtp
      adapter -> raise "Invalid email adapter: #{adapter}"
    end
  end

  @doc ~S"""
  Returns the SMTP username to use.

  ## Parameters

  - `env` - The environment variables to use. Defaults to `System.get_env()`.

  ## Returns

  - `String.t()` - The SMTP username.

  ## Example

  > iex> Glossia.Environment.email_smtp_username()
  "tonystark"
  """
  def email_smtp_username(env \\ System.get_env()) do
    Map.get(env, @email_smtp_username_env_var)
  end

  @doc ~S"""
  Returns the SMTP password to use.

  ## Parameters

  - `env` - The environment variables to use. Defaults to `System.get_env()`.

  ## Returns

  - `String.t()` - The SMTP password.

  ## Example

  > iex> Glossia.Environment.email_smtp_password()
  "ilovepepperpotts"
  """
  def email_smtp_password(env \\ System.get_env()) do
    Map.get(env, @email_smtp_password_env_var)
  end

  @doc ~S"""
  Returns the SMTP relay to use.

  ## Parameters

  - `env` - The environment variables to use. Defaults to `System.get_env()`.

  ## Returns
  - `String.t()` - The SMTP relay.

  ## Example

  > iex> Glossia.Environment.email_smtp_relay()
  "smtp.avengers.com"
  """
  def email_smtp_relay(env \\ System.get_env()) do
    Map.get(env, @email_smtp_relay_env_var)
  end

  @doc ~S"""
  Returns the SMTP port to use.

  ## Parameters

  - `env` - The environment variables to use. Defaults to `System.get_env()`.

  ## Returns

  - `integer()` - The SMTP port.

  ## Example

  > iex> Glossia.Environment.email_smtp_port()
  """
  def email_smtp_port(env \\ System.get_env()) do
    case Map.get(env, @email_smtp_port_env_var) do
      nil -> nil
      port -> String.to_integer(port)
    end
  end

  @doc ~S"""
  Returns the SMTP retries to use.

  ## Parameters

  - `env` - The environment variables to use. Defaults to `System.get_env()`.

  ## Returns

  - `integer()` - The SMTP retries.

  ## Example

  > iex> Glossia.Environment.email_smtp_retries()
  """
  def email_smtp_retries(env \\ System.get_env()) do
    case Map.get(env, @email_smtp_retries_env_var) do
      nil -> 2
      retries -> String.to_integer(retries)
    end
  end

  @doc ~S"""
  Returns whether to use no MX lookups.

  ## Parameters

  - `env` - The environment variables to use. Defaults to `System.get_env()`.

  ## Returns

  - `boolean()` - Whether to use no MX lookups.

  ## Example

  > iex> Glossia.Environment.email_smtp_no_mx_lookups()
  true
  """
  def email_smtp_no_mx_lookups(env \\ System.get_env()) do
    case Map.get(env, @email_smtp_no_mx_lookups_env_var) do
      nil -> true
      value when is_binary(value) -> truthy?(value)
      _ -> false
    end
  end

  @doc ~S"""
  Returns the SMTP authentication to use.

  ## Parameters

  - `env` - The environment variables to use. Defaults to `System.get_env()`.

  ## Returns

  - `atom()` - The SMTP authentication.

  ## Example

  > iex> Glossia.Environment.email_smtp_auth()
  :always
  """
  def email_smtp_auth(env \\ System.get_env()) do
    case Map.get(env, @email_smtp_auth_env_var) do
      nil ->
        :if_available

      value when is_binary(value) and value in ["always", "never", "if_available"] ->
        String.to_atom(value)

      _ ->
        :if_available
    end
  end

  @doc ~S"""
  Returns whether to use SSL.

  ## Parameters

  - `env` - The environment variables to use. Defaults to `System.get_env()`.

  ## Returns

  - `boolean()` - Whether to use SSL.

  ## Example

  > iex> Glossia.Environment.email_smtp_ssl()
  true
  """
  def email_smtp_ssl(env \\ System.get_env()) do
    case Map.get(env, @email_smtp_ssl_env_var) do
      nil -> false
      value when is_binary(value) -> truthy?(value)
      _ -> false
    end
  end

  @doc ~S"""
  Returns whether to use TLS.

  ## Parameters

  - `env` - The environment variables to use. Defaults to `System.get_env()`.

  ## Returns

  - `atom()` - Whether to use TLS.

  ## Example

  > iex> Glossia.Environment.email_smtp_tls()
  :always
  """
  def email_smtp_tls(env \\ System.get_env()) do
    case Map.get(env, @email_smtp_tls_env_var) do
      nil ->
        :if_available

      value when is_binary(value) and value in ["always", "never", "if_available"] ->
        String.to_atom(value)

      _ ->
        :if_available
    end
  end

  defp truthy?(value) when is_binary(value) do
    value in ["true", "1", "yes", "y", "TRUE", "1", "YES", "Y"]
  end

  def raise_when_required_absent do
    case check_missing_email_env_variables([]) do
      [] ->
        :ok

      missing_env_variables ->
        raise "Missing environment variables: #{Glossia.Formatters.String.enumerate(missing_env_variables)}"
    end
  end

  def check_missing_email_env_variables(missing_env_variables \\ [], env \\ System.get_env()) do
    missing_vars = Enum.filter(@email_smtp_required_vars, fn var -> Map.get(env, var) == nil end)
    missing_env_variables ++ missing_vars
  end
end
