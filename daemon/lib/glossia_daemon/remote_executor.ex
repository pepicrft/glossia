defmodule GlossiaDaemon.RemoteExecutor do
  @moduledoc """
  Manages remote execution of tasks across different environments and platforms.
  """

  require Logger

  @doc """
  Executes a task in a remote environment.
  
  ## Parameters
  
    * `task` - The task to execute
    * `connection` - Connection details for the remote environment
    * `opts` - Additional options
  
  ## Examples
  
      iex> GlossiaDaemon.RemoteExecutor.execute(
      ...>   %{type: :command, cmd: "ls -la"},
      ...>   %{type: :ssh, host: "example.com", user: "deploy"},
      ...>   timeout: 30_000
      ...> )
      {:ok, %{output: "...", exit_code: 0}}
  
  """
  def execute(task, connection, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, 60_000)
    
    case connection do
      %{type: :local} ->
        execute_local(task, opts)
        
      %{type: :ssh} = ssh_conn ->
        execute_ssh(task, ssh_conn, timeout)
        
      %{type: :docker} = docker_conn ->
        execute_docker(task, docker_conn, timeout)
        
      %{type: :kubernetes} = k8s_conn ->
        execute_kubernetes(task, k8s_conn, timeout)
        
      _ ->
        {:error, :unsupported_connection_type}
    end
  end

  @doc """
  Executes multiple tasks in parallel.
  """
  def execute_parallel(tasks, connection, opts \\ []) do
    max_concurrency = Keyword.get(opts, :max_concurrency, 10)
    
    tasks
    |> Task.async_stream(
      fn task -> execute(task, connection, opts) end,
      max_concurrency: max_concurrency,
      timeout: :infinity
    )
    |> Enum.map(fn {:ok, result} -> result end)
  end

  @doc """
  Executes tasks in sequence, stopping on first failure.
  """
  def execute_sequence(tasks, connection, opts \\ []) do
    Enum.reduce_while(tasks, {:ok, []}, fn task, {:ok, results} ->
      case execute(task, connection, opts) do
        {:ok, result} ->
          {:cont, {:ok, results ++ [result]}}
        {:error, _} = error ->
          {:halt, error}
      end
    end)
  end

  defp execute_local(task, opts) do
    environment = Keyword.get(opts, :environment, %{})
    
    case task do
      %{type: :command, cmd: cmd} ->
        run_local_command(cmd, environment)
        
      %{type: :script, script: script} ->
        run_local_script(script, environment)
        
      _ ->
        {:error, :unsupported_task_type}
    end
  end

  defp execute_ssh(task, %{host: host, user: user} = conn, _timeout) do
    port = Map.get(conn, :port, 22)
    key_file = Map.get(conn, :key_file)
    
    ssh_command = build_ssh_command(host, user, port, key_file, task)
    
    case System.cmd("ssh", ssh_command, stderr_to_stdout: true) do
      {output, 0} ->
        {:ok, %{output: output, exit_code: 0}}
      {output, exit_code} ->
        {:error, %{output: output, exit_code: exit_code}}
    end
  end

  defp execute_docker(task, %{container: container} = conn, _timeout) do
    docker_host = Map.get(conn, :docker_host, "unix:///var/run/docker.sock")
    
    docker_command = build_docker_command(container, docker_host, task)
    
    case System.cmd("docker", docker_command, stderr_to_stdout: true) do
      {output, 0} ->
        {:ok, %{output: output, exit_code: 0}}
      {output, exit_code} ->
        {:error, %{output: output, exit_code: exit_code}}
    end
  end

  defp execute_kubernetes(task, %{pod: pod, namespace: namespace} = conn, _timeout) do
    context = Map.get(conn, :context)
    container = Map.get(conn, :container)
    
    kubectl_command = build_kubectl_command(pod, namespace, context, container, task)
    
    case System.cmd("kubectl", kubectl_command, stderr_to_stdout: true) do
      {output, 0} ->
        {:ok, %{output: output, exit_code: 0}}
      {output, exit_code} ->
        {:error, %{output: output, exit_code: exit_code}}
    end
  end

  defp run_local_command(cmd, environment) do
    env_vars = Map.get(environment, :env_vars, %{})
    working_dir = Map.get(environment, :working_dir, ".")
    
    opts = [
      cd: working_dir,
      env: Enum.map(env_vars, fn {k, v} -> {to_string(k), to_string(v)} end),
      stderr_to_stdout: true
    ]
    
    case System.cmd("sh", ["-c", cmd], opts) do
      {output, 0} ->
        {:ok, %{output: output, exit_code: 0}}
      {output, exit_code} ->
        {:error, %{output: output, exit_code: exit_code}}
    end
  end

  defp run_local_script(script, environment) do
    temp_file = Path.join(System.tmp_dir!(), "glossia_script_#{:rand.uniform(1000000)}.sh")
    
    try do
      File.write!(temp_file, script)
      File.chmod!(temp_file, 0o755)
      run_local_command(temp_file, environment)
    after
      File.rm(temp_file)
    end
  end

  defp build_ssh_command(host, user, port, key_file, task) do
    base_args = [
      "-o", "StrictHostKeyChecking=no",
      "-o", "UserKnownHostsFile=/dev/null",
      "-p", to_string(port),
      "#{user}@#{host}"
    ]
    
    base_args = if key_file do
      ["-i", key_file | base_args]
    else
      base_args
    end
    
    case task do
      %{type: :command, cmd: cmd} ->
        base_args ++ [cmd]
      %{type: :script, script: script} ->
        base_args ++ ["sh -c '#{escape_shell(script)}'"]
    end
  end

  defp build_docker_command(container, docker_host, task) do
    base_args = if docker_host != "unix:///var/run/docker.sock" do
      ["-H", docker_host, "exec", container]
    else
      ["exec", container]
    end
    
    case task do
      %{type: :command, cmd: cmd} ->
        base_args ++ ["sh", "-c", cmd]
      %{type: :script, script: script} ->
        base_args ++ ["sh", "-c", script]
    end
  end

  defp build_kubectl_command(pod, namespace, context, container, task) do
    base_args = ["exec", "-n", namespace, pod]
    
    base_args = if context do
      ["--context", context | base_args]
    else
      base_args
    end
    
    base_args = if container do
      base_args ++ ["-c", container]
    else
      base_args
    end
    
    case task do
      %{type: :command, cmd: cmd} ->
        base_args ++ ["--", "sh", "-c", cmd]
      %{type: :script, script: script} ->
        base_args ++ ["--", "sh", "-c", script]
    end
  end

  defp escape_shell(str) do
    String.replace(str, "'", "'\\''")
  end
end