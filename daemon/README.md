# GlossiaDaemon

A daemon library for running operations in remote environments for the Glossia platform.

## Features

- Execute commands and scripts in local and remote environments
- Support for multiple execution environments (SSH, Docker, Kubernetes)
- Parallel and sequential task execution
- Configurable timeouts and error handling

## Installation

This library is used locally by the Glossia web application. It's not published to Hex.

## Usage

### Basic Usage

```elixir
# Execute a local command
task = %{type: :command, cmd: "echo 'Hello, World!'"}
connection = %{type: :local}
{:ok, result} = GlossiaDaemon.RemoteExecutor.execute(task, connection)

# Execute via SSH
ssh_task = %{type: :command, cmd: "ls -la"}
ssh_conn = %{type: :ssh, host: "example.com", user: "deploy"}
{:ok, result} = GlossiaDaemon.RemoteExecutor.execute(ssh_task, ssh_conn)
```

### Using the Runner

```elixir
{:ok, runner} = GlossiaDaemon.Runner.start_link(id: "my-runner")

# Queue tasks
GlossiaDaemon.Runner.queue_task(runner, %{type: :command, cmd: "echo 'Task 1'"})
GlossiaDaemon.Runner.queue_task(runner, %{type: :command, cmd: "echo 'Task 2'"})

# Execute all queued tasks
{:ok, results} = GlossiaDaemon.Runner.execute(runner)
```

### Parallel Execution

```elixir
tasks = [
  %{type: :command, cmd: "task1"},
  %{type: :command, cmd: "task2"},
  %{type: :command, cmd: "task3"}
]

connection = %{type: :local}
results = GlossiaDaemon.RemoteExecutor.execute_parallel(tasks, connection, max_concurrency: 2)
```

## Development

Run tests:
```bash
mix test
```

Format code:
```bash
mix format
```

Run linter:
```bash
mix credo
```