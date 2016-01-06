defmodule ExAwsGenTest do
  use ExUnit.Case

  test "the truth" do
    :sns
    |> ExAwsGen.Service.build
    |> IO.inspect
  end

  test "#build_name_map" do
    %{
      "FooBar" => "Baz",
      "Flag" => %{
        "Asdf" => "Blurg"
      },
      "ListThing" => [
        "List", "of", "values"
      ],
      "OtherListThing" => [
        %{
          "ListOf" => "maps"
        }
      ]
    }
    |> ExAwsGen.Service.build_name_map
    |> IO.inspect
  end
end
