defmodule ExAwsGen.Service do
  defstruct [:name, :docs, :module, :protocol, :metadata, :operations, :slug, :test_op, :namespace]
  @black_list [:dynamodb, :s3, :kinesis, :lambda]
  @api_root "./priv/apis/"

  def all do
    Application.get_env(:ex_aws_gen, :services)
    :maps.without @black_list, services
  end

  def build(slug) do
    service_spec = @services[slug]

    path = @api_root <> service_spec[:path] <> "/"
    api  = get_api(path)
    docs = get_docs(path)

    %__MODULE__{
      slug: slug,
      protocol: api["metadata"]["protocol"],
      operations: api["operations"],
      metadata: api["metadata"],
      docs: docs,
      name: service_spec[:module],
      module: service_spec[:module],
      test_op: service_spec[:test_op],
      namespace: service_spec[:namespace]
    }
  end

  def get_api(path) do
    File.read!(path <> "api-2.json")
    |> Poison.decode!
  end

  def get_docs(path) do
    File.read!(path <> "docs-2.json")
    |> Poison.decode!
    |> Map.get("operations")
    |> Enum.into(%{}, fn {k, v} ->
      {k, ExAwsGen.DocParser.format(v)}
    end)
  end
end
