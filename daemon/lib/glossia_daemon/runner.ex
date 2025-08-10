defmodule GlossiaDaemon.Runner do
  @moduledoc """
  Handles the execution of various types of operations in remote environments.
  """

  use GenServer
  require Logger

  defstruct [:id, :environment, :tasks, :status]

  @doc """
  Starts a new runner process.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  @impl true
  def init(opts) do
    state = %__MODULE__{
      id: Keyword.get(opts, :id, generate_id()),
      environment: Keyword.get(opts, :environment, %{}),
      tasks: [],
      status: :ready
    }
    
    {:ok, state}
  end

  @doc """
  Queues a task for execution.
  """
  def queue_task(runner, task) do
    GenServer.call(runner, {:queue_task, task})
  end

  @doc """
  Executes all queued tasks.
  """
  def execute(runner) do
    GenServer.call(runner, :execute, :infinity)
  end

  @doc """
  Gets the current status of the runner.
  """
  def get_status(runner) do
    GenServer.call(runner, :get_status)
  end

  @impl true
  def handle_call({:queue_task, task}, _from, state) do
    updated_state = %{state | tasks: state.tasks ++ [task]}
    {:reply, :ok, updated_state}
  end

  @impl true
  def handle_call(:execute, _from, state) do
    results = Enum.map(state.tasks, &execute_single_task(&1, state.environment))
    {:reply, {:ok, results}, %{state | tasks: [], status: :completed}}
  end

  @impl true
  def handle_call(:get_status, _from, state) do
    {:reply, state, state}
  end

  defp execute_single_task(task, environment) do
    Logger.info("Executing task: #{inspect(task)}")
    
    case task do
      %{type: :command, cmd: cmd} ->
        run_command(cmd, environment)
        
      %{type: :script, script: script} ->
        run_script(script, environment)
        
      %{type: :function, fun: fun} ->
        run_function(fun, environment)
        
      _ ->
        {:error, :unsupported_task_type}
    end
  end

  defp run_command(cmd, environment) do
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

  defp run_script(script, environment) do
    temp_file = Path.join(System.tmp_dir!(), "glossia_daemon_#{:rand.uniform(1000000)}.sh")
    
    try do
      File.write!(temp_file, script)
      File.chmod!(temp_file, 0o755)
      run_command(temp_file, environment)
    after
      File.rm(temp_file)
    end
  end

  defp run_function(fun, environment) when is_function(fun) do
    try do
      result = fun.(environment)
      {:ok, result}
    rescue
      error ->
        {:error, Exception.message(error)}
    end
  end

  defp generate_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end
end