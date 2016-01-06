defmodule ExAwsGen do
  alias ExAwsGen.Context

  @output "./priv/output"
  # @output "../ex_aws"
  @lib_root @output <> "/lib/ex_aws/"
  @test_root @output <> "/test/lib/ex_aws/"
  @templates_dir "./lib/ex_aws_gen/templates/"

  def paths do
    %{
      output: @output,
      lib_root: @lib_root,
      test_root: @test_root,
      templates: @templates_dir,
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

  def generate_service(%{slug: slug} = service) do
    service |> mk_dirs

    service
    |> write_template(Context.Api, "api.ex.eex", @lib_root <> "#{slug}/api.ex")
    # |> write_template(Context.Service, "service.ex.eex", @lib_root <> "#{slug}.ex")
    # |> write_template(Context.Test, "test.ex.eex", @test_root <> "#{slug}_test.exs")
  end

  def write_template(%{protocol: protocol} = service, context, template, destination) do
    IO.puts "Generating #{service.name} #{destination} with #{context}"

    content = @templates_dir <> "#{protocol}/#{template}"
    |> File.read!
    |> EEx.eval_string(assigns: context.build(service))

    File.write!(destination, content)
    service
  end

  def files(%{slug: slug}) do
    [
      @lib_root <> "#{slug}/api.ex",
      @lib_root <> "#{slug}.ex",
      @test_root <> "#{slug}_test.exs",
    ]
  end

  def delete_stuff(service) do
    service
    |> files
    |> Enum.map(&File.rm(&1))
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
