defmodule ExAwsGen.Context.Service do
  def build(service), do: Map.from_struct(service)
end
