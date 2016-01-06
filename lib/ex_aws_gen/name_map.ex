defmodule ExAwsGen.NameMap do
  def build(slug, api, mapping \\ %{}) do
    do_build(api, mapping)
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
        do_build(v, Map.put(acc, k, transform(k)))
      {k, v}, acc when is_list(v) ->
        do_build(v, Map.put(acc, k, transform(k)))
      {k, v}, acc when is_binary(v) ->
        acc
        |> Map.put(k, transform(k))
        |> Map.put(v, transform(v))
      {k, _}, acc ->
        Map.put(acc, k, transform(k))
    end)
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
