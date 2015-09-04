defmodule ExAwsGen do

  @lib_root "../ex_aws/lib/ex_aws/"
  @test_root "../ex_aws/test/lib/ex_aws/"
  # @output "./priv/output/"
  @templates "./priv/templates/"

  def generate(service) do
    service
    |> files
    |> Enum.map(&generate_file(&1, service))
  end

  def generate_file({template, output}, %{protocol: protocol} = service) do
    IO.puts "Generating #{service.name} #{output}"
    content = @templates <> "#{protocol}/#{template}"
    |> File.read!
    |> EEx.eval_string(assigns: service |> Map.from_struct)

    File.mkdir(lib_dir(service))
    File.mkdir(test_dir(service))
    File.write!(output, content)
  end

  def delete_stuff(service) do
    service
    |> files
    |> Enum.map(&File.rm(&1))
  end

  def files(service) do
    %{
      "core.ex.eex" => @lib_root <> "#{service.slug}/core.ex",
      "request.ex.eex" => @lib_root <> "#{service.slug}/request.ex",
      "service.ex.eex" => @lib_root <> "#{service.slug}.ex",
      "test.ex.eex" => @test_root <> "#{service.slug}_test.exs"
    }
  end

  def lib_dir(service) do
    [@lib_root, service.slug] |> Enum.join
  end

  def test_dir(service) do
    [@test_root, "../test/ex_aws/", service.slug] |> Enum.join
  end
end
