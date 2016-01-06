defmodule ExAwsGen.Typespec do
  ## ["list", "structure", "string", "boolean", "integer", "double", "timestamp",
  ##  "map", "long", "blob", "float"]

  @builtin_types ~w(boolean string integer float binary Boolean String Integer Float Binary)

  def build(%{aws_api: api_doc, name_map: mapping}) do
    api_doc["shapes"]
    |> Enum.map(&type_specs_for_shape(&1, mapping))
    |> Enum.map(fn
      [] -> []
      iolist -> [iolist, "\n\n"]
    end)
    |> IO.iodata_to_binary
  end

  def type_specs_for_shape({type, _}, _) when type in @builtin_types, do: []

  def type_specs_for_shape({type, %{"type" => "list", "member" => %{"shape" => member}}}, aliases) do
    ["  @type ", Map.fetch!(aliases, type), " :: [", member_type(member, aliases), "]"]
  end
  def type_specs_for_shape({type, %{"type" => "structure", "members" => members}}, aliases) do
    member_specs = Enum.map(members, fn {member_name, member} ->
      [Mix.Utils.underscore(member_name), ": ", member_type(member["shape"], aliases), ",\n"]
    end)
    [
      "  @type ", Map.fetch!(aliases, type), " :: [\n",
      Enum.map(member_specs, &(["    " | &1])),
      "  ]"
    ]
  end
  def type_specs_for_shape({type, %{"type" => "string"}}, aliases) do
    ["  @type ", Map.fetch!(aliases, type), " :: binary"]
  end
  def type_specs_for_shape({type, %{"type" => "boolean"}}, aliases) do
    ["  @type ", Map.fetch!(aliases, type), " :: boolean"]
  end
  def type_specs_for_shape({type, %{"type" => "integer"}}, aliases) do
    ["  @type ", Map.fetch!(aliases, type), " :: integer"]
  end
  def type_specs_for_shape({type, %{"type" => "double"}}, aliases) do
    ["  @type ", Map.fetch!(aliases, type), " :: float"]
  end
  def type_specs_for_shape({type, %{"type" => "timestamp"}}, aliases) do
    ["  @type ", Map.fetch!(aliases, type), " :: integer"]
  end
  def type_specs_for_shape({type, %{"type" => "map", "key" => key, "value" => value}}, aliases) do
    ["  @type ", Map.fetch!(aliases, type), " :: [{", member_type(key, aliases), ", ", member_type(value, aliases), "}]"]
  end
  def type_specs_for_shape({type, %{"type" => "long"}}, aliases) do
    ["  @type ", Map.fetch!(aliases, type), " :: integer"]
  end
  def type_specs_for_shape({type, %{"type" => "blob"}}, aliases) do
    ["  @type ", Map.fetch!(aliases, type), " :: binary"]
  end
  def type_specs_for_shape({type, %{"type" => "float"}}, aliases) do
    ["  @type ", Map.fetch!(aliases, type), " :: float"]
  end
  def type_specs_for_shape({type, %{"type" => aws_type}}, _) do
    IO.puts("Ignoring: #{type} of type: #{aws_type}")
    []
  end

  def member_type(%{"shape" => shape}, aliases), do: member_type(shape, aliases)
  def member_type(shape, aliases), do: Map.fetch!(aliases, shape)

end
