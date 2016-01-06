defmodule ExAwsGen.Service do
  defstruct name: nil,
    name_map: %{},
    protocol: nil,
    inverse_name_map: %{},
    aws_api: %{},
    module: nil,
    protocol: nil,
    slug: nil,
    test_config: %{},
    namespace: nil,
    version: nil,
    aws_docs: nil


  @black_list [:dynamodb, :s3, :kinesis, :lambda, :support, :device_farm, :sqs]

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
    service_spec = @services[slug]

    path     = @api_root <> service_spec[:path] <> "/"
    api      = api_json(path)
    docs     = get_docs(path)
    name_map = ExAwsGen.NameMap.build(slug, api)



    %__MODULE__{
      aws_api:     api,
      aws_docs:    docs,
      name_map:    name_map,
      slug:        slug,
      protocol:    api["metadata"]["protocol"],
      name:        service_spec[:module],
      module:      service_spec[:module],
      test_config: service_spec[:test_config],
      namespace:   service_spec[:namespace],
      version:     service_spec[:path] |> String.split("/") |> List.last,
      inverse_name_map: name_map |> Enum.into(%{}, fn {k, v} -> {v, k} end),
    }
  end

  def api_json(path) do
    File.read!(path <> "api-2.json")
    |> Poison.decode!
  end

  def get_docs(path) do
    File.read!(path <> "docs-2.json")
    |> Poison.decode!
  end

  def permissions do
    all
    |> Enum.reduce([], fn
      {_, %{test_config: %{fun: fun}, namespace: namespace}}, permissions -> ["#{namespace}:#{Mix.Utils.camelize(fun)}" | permissions]
      {_, %{test_config: fun, namespace: namespace}}, permissions -> ["#{namespace}:#{Mix.Utils.camelize(fun)}" | permissions]
      _, permissions -> permissions
    end)
  end
end
