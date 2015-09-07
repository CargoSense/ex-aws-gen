defmodule ExAwsGen.TestHelper do
  def test_fun(%{fun: fun}), do: fun
  def test_fun(fun) when is_binary(fun), do: fun
  def test_fun(fun), do: "does_not_exist"

  def json_args(%{args: args}), do: args
  def json_args(_), do: %{}

  def query_args(%{args: args}), do: args
  def query_args(_), do: []
end
