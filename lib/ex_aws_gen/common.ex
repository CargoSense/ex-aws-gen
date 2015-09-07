defmodule ExAwsGen.Common do

  def generate(paths, protocol) do
    paths
    |> files(protocol)
    |> Enum.map(&generate_file(&1, paths, protocol))
  end

  def generate_file({template, output}, paths, protocol) do
    IO.puts "Generating #{protocol} #{output}"

    content = paths.templates <> template
    |> File.read!
    |> EEx.eval_string(assigns: %{protocol: protocol})

    File.mkdir_p(paths.lib_root <> "/request")
    File.mkdir_p(paths.lib_root <> "/core")
    File.write!(output, content)
  end

  def files(paths, protocol) do
    # can't interpolate in map key literals
    %{}
    |> Map.put("#{protocol}/utils.ex.eex", paths.lib_root <> "core/#{protocol |> ExAwsGen.Service.protocol_file}.ex")
    |> Map.put("#{protocol}/request.ex.eex", paths.lib_root <> "request/#{protocol}.ex")
  end
end
