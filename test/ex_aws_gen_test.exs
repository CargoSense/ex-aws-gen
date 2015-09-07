defmodule ExAwsGenTest do
  use ExUnit.Case

  test "the truth" do
    ExAwsGen.Service.all_parsed
    |> Enum.take(1)
    |> List.first
    |> Map.get(:api)
    |> Map.get("shapes")
    |> Enum.to_list
    |> List.first
    |> ExAwsGen.Typespec.type_specs_for_shape
    |> IO.inspect
  end
end
