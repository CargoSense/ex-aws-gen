defmodule Mix.Tasks.Generate do
  @shortdoc "Generate an API"

  def run(["--protocol", protocol]) do
    ExAwsGen.Service.all
    |> Map.keys
    |> Stream.map(&ExAwsGen.Service.build/1)
    |> Stream.filter(&(&1.protocol == protocol))
    |> Enum.map(&ExAwsGen.generate/1)
  end

  def run([slug]) do
    slug
    |> String.to_atom
    |> ExAwsGen.Service.build
    |> ExAwsGen.generate
  end
end
