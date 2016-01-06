defmodule ExAwsGen.NameMap do
  def build(slug, api, mapping \\ %{}) do
    op_mapping = do_build(api["operations"], mapping)

    do_build(api["shapes"], op_mapping)
    |> Map.put("Record", "#{slug}_record")
    |> Map.put("Integer", "integer")
    |> Map.put("String", "binary")
    |> Map.put("string", "binary")
  end

  def do_build(api, mapping) do
    Enum.reduce(api, mapping, fn
      "" <> item, acc ->
        Map.put(acc, item, transform(item))
      %{} = item, acc ->
        do_build(item, acc)
      {k, %{} = v}, acc ->
        do_build(v, add_mapping(acc, k, transform(k)))
      {k, v}, acc when is_list(v) ->
        do_build(v, add_mapping(acc, k, transform(k)))
      {k, v}, acc when is_binary(v) ->
        acc
        |> add_mapping(k, transform(k))
        |> add_mapping(v, transform(v))
      {k, _}, acc ->
        add_mapping(acc, k, transform(k))
    end)
  end

  @doc """
  Only add an item to the mapping if the transformed
  version is different than the AWS version
  """
  def add_mapping(acc, k, v) do
    # case transform(v) do
    #   ^k -> acc
    #   transformed -> Map.put(acc, k, transformed)
    # end
    Map.put(acc, k, transform(v))
  end

  def transform("EC2" <> rest) do
    "ec2_#{transform(rest)}"
  end
  def transform(item) do
    item
    |> Macro.underscore
    |> String.replace("m_d5", "md5")
  end
end
