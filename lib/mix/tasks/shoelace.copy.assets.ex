defmodule Mix.Tasks.Shoelace.Copy.Assets do
  @shortdoc "Copies vendor assets to priv/static"

  use Mix.Task

  def run(_) do
    source = "node_modules/@shoelace-style/shoelace/dist/assets"
    dest = "priv/static/assets/shoelace"

    # Delete destination folder if it exists
    if File.exists?(dest) do
      File.rm_rf!(dest)
      Mix.shell().info("Removed existing #{dest}")
    end

    # Copy the assets
    File.cp_r!(source, dest)
    Mix.shell().info("Assets copied successfully")
  end
end
