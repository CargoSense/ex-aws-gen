defmodule ExAwsGen.Service do
  alias ExAwsGen.Typespec
  defstruct [
    :name,
    :docs,
    :api,
    :module,
    :protocol,
    :metadata,
    :slug,
    :test_config,
    :type_info,
    :namespace,
    :version
  ]

  @black_list [:dynamodb, :s3, :kinesis, :lambda, :support, :device_farm]

  @api_root "./priv/apis/"

  @services "./priv/services.json"
  |> File.read!
  |> Poison.decode!(keys: :atoms)

  def all do
    :maps.without @black_list, @services
  end

  def all_parsed do
    all
    |> Map.keys
    |> Stream.map(&build/1)
  end

  def build(slug) do
    IO.puts "Generating #{slug}"

    service_spec = @services[slug]

    path = @api_root <> service_spec[:path] <> "/"
    api  = get_api(path)
    docs = get_docs(path)

    %__MODULE__{
      slug: slug,
      protocol: api["metadata"]["protocol"],
      metadata: api["metadata"],
      api: api,
      docs: docs,
      name: service_spec[:module],
      module: service_spec[:module],
      test_config: service_spec[:test_config],
      namespace: service_spec[:namespace],
      type_info: Typespec.build(api["shapes"], slug),
      version: service_spec[:path] |> String.split("/") |> List.last,
    }
  end

  def get_api(path) do
    File.read!(path <> "api-2.json")
    |> Poison.decode!
  end

  def get_docs(path) do
    docs = File.read!(path <> "docs-2.json")
    |> Poison.decode!

    docs
    |> update_in(["operations"], &Enum.into(&1, %{}, fn {k, v} ->
      {k, ExAwsGen.DocParser.format(v)}
    end))
  end

  def protocol_name("json"), do: "JSON"
  def protocol_name("query"), do: "Query"
  def protocol_file("json"), do: "json"
  def protocol_file("query"), do: "query"

  def permissions do
    all
    |> Enum.reduce([], fn
      {_, %{test_config: %{fun: fun}, namespace: namespace}}, permissions -> ["#{namespace}:#{Mix.Utils.camelize(fun)}" | permissions]
      {_, %{test_config: fun, namespace: namespace}}, permissions -> ["#{namespace}:#{Mix.Utils.camelize(fun)}" | permissions]
      _, permissions -> permissions
    end)
  end
end
