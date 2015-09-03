defmodule ExAwsGen.Service do
  defstruct [:name, :api, :docs, :module]
  @api_root "./priv/apis/"
  @services "./priv/services.json"
  |> File.read!
  |> Poison.decode!(keys: :atoms)

  def build(name) do
    service_spec = @services[name]

    path = @api_root <> service_spec[:path] <> "/"
    api  = File.read!(path <> "api-2.json")
    |> Poison.decode!
    docs = get_docs(path)

    %__MODULE__{name: name, api: api, docs: docs, module: service_spec[:module]}
  end

  def get_docs(path) do
    docs = File.read!(path <> "docs-2.json")
    |> Poison.decode!

    update_in(docs, ["operations"], &Enum.into(&1, %{}, fn
      {k, v} -> {k, ExAwsGen.DocParser.format(v)}
    end))
  end
end
