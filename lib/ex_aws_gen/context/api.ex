defmodule ExAwsGen.Context.Api do
  alias ExAwsGen.Typespec

  def build(service) do
    %{
      request_module: service.protocol |> request_module,
      metadata: service.aws_api["metadata"],
      module: service.module,
      operations: build_operations(service),
      typespecs: Typespec.build(service),
      uri: service.aws_api["http"]["requestUri"],
      docs: build_docs(service),
      module_doc: service.aws_docs["service"] |> ExAwsGen.DocParser.format(service.name_map)
    }
  end

  def build_operations(%{name_map: mapping} = service) do
    Enum.reduce(service.aws_api["operations"], %{}, fn {name, data}, ops ->
      input_type_name = case data do
        %{"input" => %{"shape" => input_type_name}} ->
          Map.fetch!(mapping, input_type_name)
        _ -> nil
      end

      info = %{
        aws_op: name,
        input_type_name: input_type_name,
      }

      Map.put(ops, Map.fetch!(mapping, name), info)
    end)
  end

  defp build_docs(%{aws_docs: aws_docs, name_map: mapping}) do
    aws_docs["operations"]
    |> Enum.into(%{}, fn {op, doc} ->
      {Map.fetch!(mapping, op), ExAwsGen.DocParser.format(doc, mapping)}
    end)
  end

  def request_module("json"),  do: "ExAws.Request.JSON"
  def request_module("query"), do: "ExAws.Request.Query"
end
