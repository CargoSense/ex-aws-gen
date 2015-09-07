defmodule ExAwsGen.Typespec do
  ## ["list", "structure", "string", "boolean", "integer", "double", "timestamp",
  ##  "map", "long", "blob", "float"]

  @builtin_types ~w(boolean string integer float binary Boolean String Integer Float Binary)

  def build(shapes, prefix) do
    aliases = shapes
    |> Enum.reduce(HashDict.new, &build_type_aliases(&1, &2, prefix))
    |> Enum.into(HashDict.new, fn {k, v} -> {v, k} end)

    # aliases |> Enum.each(&IO.inspect/1)

    shapes
    |> Enum.map(&type_specs_for_shape(&1, aliases))
    |> Enum.map(fn
      [] -> []
      iolist -> [iolist, "\n\n"]
    end)
    |> IO.iodata_to_binary
  end

  def type_specs_for_shape({type, _}, _) when type in @builtin_types, do: []

  def type_specs_for_shape({type, %{"type" => "list", "member" => %{"shape" => member}}}, aliases) do
    ["  @type ", HashDict.fetch!(aliases, type), " :: [", member_type(member, aliases), "]\n\n"]
  end
  def type_specs_for_shape({type, %{"type" => "structure", "members" => members}}, aliases) do
    member_specs = Enum.map(members, fn {member_name, member} ->
      [Mix.Utils.underscore(member_name), ": ", member_type(member["shape"], aliases), ",\n"]
    end)
    [
      "  @type ", HashDict.fetch!(aliases, type), " :: [\n",
      Enum.map(member_specs, &(["    " | &1])),
      "  ]"
    ]
  end
  def type_specs_for_shape({type, %{"type" => "string"}}, aliases) do
    ["  @type ", HashDict.fetch!(aliases, type), " :: binary"]
  end
  def type_specs_for_shape({type, %{"type" => "boolean"}}, aliases) do
    ["  @type ", HashDict.fetch!(aliases, type), " :: boolean"]
  end
  def type_specs_for_shape({type, %{"type" => "integer"}}, aliases) do
    ["  @type ", HashDict.fetch!(aliases, type), " :: integer"]
  end
  def type_specs_for_shape({type, %{"type" => "double"}}, aliases) do
    ["  @type ", HashDict.fetch!(aliases, type), " :: float"]
  end
  def type_specs_for_shape({type, %{"type" => "timestamp"}}, aliases) do
    ["  @type ", HashDict.fetch!(aliases, type), " :: integer"]
  end
  def type_specs_for_shape({type, %{"type" => "map", "key" => key, "value" => value}}, aliases) do
    ["  @type ", HashDict.fetch!(aliases, type), " :: [{", member_type(key, aliases), ", ", member_type(value, aliases), "}]"]
  end
  def type_specs_for_shape({type, %{"type" => "long"}}, aliases) do
    ["  @type ", HashDict.fetch!(aliases, type), " :: integer"]
  end
  def type_specs_for_shape({type, %{"type" => "blob"}}, aliases) do
    ["  @type ", HashDict.fetch!(aliases, type), " :: binary"]
  end
  def type_specs_for_shape({type, %{"type" => "float"}}, aliases) do
    ["  @type ", HashDict.fetch!(aliases, type), " :: float"]
  end
  def type_specs_for_shape({type, %{"type" => aws_type}}, _) do
    IO.puts("Ignoring: #{type} of type: #{aws_type}")
    []
  end

  def member_type(%{"shape" => shape}, aliases), do: member_type(shape, aliases)
  def member_type(shape, aliases), do: HashDict.fetch!(aliases, shape)

  @doc """
  Alias AWS shape name to elixir typespec name.

  Ordinarily a simple Mix.Utils.underscore would do but
  certain AWS APIs have two shapes that when underscored have the same name.
  IE: Endpoint and endpoint. This ensures that the latter are uniformly aliased.
  """
  def build_type_aliases({type_name, _}, aliases, prefix) do
    elixir_name = elixir_type_name(type_name, prefix)
    case HashDict.fetch(aliases, elixir_name) do
      {:ok, _} -> HashDict.put(aliases, elixir_name <> "_name", type_name)
      :error -> HashDict.put(aliases, elixir_name, type_name)
    end
  end

  def elixir_type_name("Record", prefix), do: "#{prefix}_record"
  def elixir_type_name("Integer", _), do: "integer"
  def elixir_type_name("String", _), do: "binary"
  def elixir_type_name("string", _), do: "binary"
  def elixir_type_name(other, _), do: Mix.Utils.underscore(other)

  @doc """
  Prefix reserved types with the service name.

  While certain AWS types like String have a parallel basic elixir type like binary,
  Record and others do not. Instead the best route here is to prefix the shape name.
  """
  @reserved_types ~w(Record)
  def handle_prefixes({k, v}, prefix) when k in @reserved_types do
    {"#{prefix}#{k}", v}
  end
  def handle_prefixes(pair, _), do: pair

end
