defmodule Glossia.Repositories do
  alias Glossia.Repositories.Schemas

  @configuration_file_name ".glossia.toml"

  def local do
    directory = Path.expand("../..", __DIR__)
    %{forge: :local, directory: directory}
  end

  def configuration(repository) do
    configuration(nil, repository)
  end

  def configuration(sha, %{forge: :local, directory: directory}) do
    with {:ok, content} <- read_file_content(sha, directory, @configuration_file_name),
         {:ok, parsed_toml} <- parse_toml(content),
         {:ok, configuration} <- Schemas.configuration(parsed_toml) do
      {:ok, configuration}
    else
      {:error, reason} -> {:error, reason}
      error -> {:error, "Unknown error: #{inspect(error)}"}
    end
  end

  def commits(%{forge: :local, directory: directory}) do
    args = [
      "log",
      ~S[--pretty=format:'{"sha":"%H","short_sha":"%h","author":"%an","email":"%ae","date":"%ad","message":"%s"}'],
      "--date=iso"
    ]

    with {:ok, output} <- run_git_command(args, directory) do
      parse_commits(output)
    end
  end

  defp read_file_content(nil, directory, filename) do
    file_path = Path.join(directory, filename)

    if File.exists?(file_path) do
      case File.read(file_path) do
        {:ok, content} -> {:ok, content}
        {:error, reason} -> {:error, "Failed to read file: #{reason}"}
      end
    else
      {:error, "Configuration file not found"}
    end
  end

  defp read_file_content(sha, directory, filename) do
    args = ["show", "#{sha}:#{filename}"]
    run_git_command(args, directory)
  end

  defp run_git_command(args, directory) do
    case MuonTrap.cmd("git", args, cd: directory, stderr_to_stdout: false) do
      {output, 0} ->
        {:ok, output}

      {error_output, exit_code} ->
        {:error, "Git command failed (exit #{exit_code}): #{error_output}"}
    end
  end

  defp parse_toml(content) do
    case TomlElixir.parse(content) do
      {:ok, parsed} -> {:ok, parsed}
      {:error, reason} -> {:error, "TOML parsing failed: #{inspect(reason)}"}
    end
  rescue
    error -> {:error, "TOML parsing error: #{inspect(error)}"}
  end

  defp parse_commits(output) do
    commits =
      output
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_commit_line/1)
      |> Enum.reject(&is_nil/1)

    {:ok, commits}
  rescue
    error -> {:error, "Failed to parse commits: #{inspect(error)}"}
  end

  defp parse_commit_line(line) do
    line
    |> String.trim("'")
    |> JSON.decode!()
    |> ExUtils.Map.symbolize_keys()
  rescue
    _ -> nil
  end
end
