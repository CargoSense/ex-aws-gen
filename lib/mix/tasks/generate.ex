defmodule Mix.Tasks.Generate do
  @shortdoc "Generate an API"

  def run(["--protocol", protocol]) do
    ExAwsGen.generate(protocol: protocol)
  end

  def run([slug]) do
    slug
    |> String.to_atom
    |> ExAwsGen.Service.build
    |> ExAwsGen.generate
  end
end
