defmodule GlossiaDaemon.CLI do
  @moduledoc """
  Entry point for the Glossia Daemon executable.
  """

  def main(args \\ []) do
    IO.puts("Glossia Daemon v#{Application.spec(:glossia_daemon, :vsn)}")
    
    case args do
      ["--version" | _] ->
        IO.puts(Application.spec(:glossia_daemon, :vsn))
        
      ["--help" | _] ->
        print_help()
        
      _ ->
        IO.puts("Starting Glossia Daemon...")
        # Add daemon logic here
        Process.sleep(:infinity)
    end
  end

  defp print_help do
    IO.puts("""
    Usage: glossia_daemon [options]

    Options:
      --version    Show version
      --help       Show this help message
    """)
  end
end