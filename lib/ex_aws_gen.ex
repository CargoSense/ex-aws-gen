defmodule ExAwsGen do

  @output "./priv/output"
  # @output "../ex_aws"
  @lib_root @output <> "/lib/ex_aws/"
  @test_root @output <> "/test/lib/ex_aws/"
  @templates "./priv/templates/"

  def paths do
    %{
      output: @output,
      lib_root: @lib_root,
      test_root: @test_root,
      templates: @templates,
    }
  end

  def generate(protocol: protocol) do
    ExAwsGen.Common.generate(paths, protocol)

    ExAwsGen.Service.all
    |> Enum.filter_map(&match?({_, %{protocol: ^protocol}}, &1), &elem(&1, 0))
    |> Enum.map(&generate_service/1)
  end

  def generate(service) do
    ExAwsGen.Common.generate(paths, service.protocol)
    generate_service(service)
  end

  def generate_service(service) do
    service = service |> ExAwsGen.Service.build
    service
    |> files
    |> Enum.map(&generate_file(&1, service))
  end

  def generate_file({template, output}, %{protocol: protocol} = service) do
    IO.puts "Generating #{service.name} #{output}"

    content = @templates <> "#{protocol}/#{template}"
    |> File.read!
    |> EEx.eval_string(assigns: service |> Map.from_struct)

    service |> mk_dirs
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
      "client.ex.eex" => @lib_root <> "#{service.slug}/client.ex",
      "test.ex.eex" => @test_root <> "#{service.slug}_test.exs"
    }
  end

  def mk_dirs(service) do
    File.mkdir_p(lib_dir(service))
    File.mkdir_p(test_dir(service))
  end

  def lib_dir(service) do
    [@lib_root, service.slug] |> Enum.join
  end

  def test_dir(service) do
    [@test_root, service.slug] |> Enum.join
  end
end
