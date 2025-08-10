defmodule GlossiaDaemon do
  @moduledoc """
  GlossiaDaemon is responsible for running operations in remote environments.
  
  This library provides functionality to execute tasks, manage remote operations,
  and handle communication with external services for the Glossia platform.
  """

  @doc """
  Starts the daemon with the given configuration.
  
  ## Options
  
    * `:name` - The name to register the daemon process under
    * `:environment` - The environment configuration (:dev, :test, :prod)
  
  ## Examples
  
      iex> {:ok, _pid} = GlossiaDaemon.start_link(name: :my_daemon, environment: :dev)
  
  """
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    environment = Keyword.get(opts, :environment, :dev)
    
    {:ok, spawn_link(fn -> init(name, environment) end)}
  end

  defp init(name, environment) do
    Process.register(self(), name)
    loop(%{name: name, environment: environment, tasks: []})
  end

  defp loop(state) do
    receive do
      {:execute, task, from} ->
        result = execute_task(task, state)
        send(from, {:result, result})
        loop(state)
        
      {:status, from} ->
        send(from, {:status, state})
        loop(state)
        
      {:stop, from} ->
        send(from, {:stopped, state.name})
        :ok
    end
  end

  @doc """
  Executes a task in the remote environment.
  
  ## Parameters
  
    * `task` - A map containing the task details
    * `opts` - Optional parameters for task execution
  
  ## Examples
  
      iex> GlossiaDaemon.execute_task(%{type: :shell, command: "echo hello"})
      {:ok, "hello\\n"}
  
  """
  def execute_task(task, opts \\ []) do
    case task do
      %{type: :shell, command: command} ->
        execute_shell_command(command, opts)
        
      %{type: :http, url: url, method: method} ->
        execute_http_request(url, method, opts)
        
      _ ->
        {:error, :unknown_task_type}
    end
  end

  defp execute_shell_command(command, _opts) do
    try do
      {output, 0} = System.cmd("sh", ["-c", command], stderr_to_stdout: true)
      {:ok, output}
    rescue
      e -> {:error, Exception.message(e)}
    end
  end

  defp execute_http_request(url, method, opts) do
    body = Keyword.get(opts, :body, "")
    headers = Keyword.get(opts, :headers, [])
    
    request = Finch.build(method, url, headers, body)
    
    case Finch.request(request, GlossiaDaemon.Finch) do
      {:ok, response} ->
        {:ok, response}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Returns the current status of the daemon.
  """
  def status(daemon \\ __MODULE__) do
    send(daemon, {:status, self()})
    receive do
      {:status, state} -> {:ok, state}
    after
      5000 -> {:error, :timeout}
    end
  end

  @doc """
  Stops the daemon gracefully.
  """
  def stop(daemon \\ __MODULE__) do
    send(daemon, {:stop, self()})
    receive do
      {:stopped, name} -> {:ok, name}
    after
      5000 -> {:error, :timeout}
    end
  end
end