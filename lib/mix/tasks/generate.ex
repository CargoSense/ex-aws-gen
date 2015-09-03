defmodule Mix.Tasks.Generate do
  @shortdoc "Generate an API"

  def run([service]) do
    service_spec = service
    |> String.to_atom
    |> ExAwsGen.Service.build

    "./priv/templates/core.ex.eex"
    |> File.read!
    |> EEx.eval_string(assigns: service_spec |> Map.from_struct)
    |> IO.puts
  end
end
