defmodule Glossia.AI do
  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatOllamaAI

  def llm(%{forge: :local} = _project) do
    %ChatOllamaAI{
      model: "gpt-oss:20b",
      temperature: 0.7
    }
  end

  def translate(%{project: project}) do
    %{llm: project |> llm(), custom_context: %{project: project}}
    |> LLMChain.new!()
    |> LLMChain.add_tools([list_source_language_files()])
  end

  defp list_source_language_files do
    LangChain.Function.new!(%{
      name: "list_source_language_files",
      description: "Return JSON object of the current users's relevant information.",
      function: fn _args, %{project: project} = _context ->
        # This uses the user_id provided through the context to call our Elixir function.
        {:ok, Jason.encode!(MyApp.get_user_info(user_id))}
      end
    })
  end
end
