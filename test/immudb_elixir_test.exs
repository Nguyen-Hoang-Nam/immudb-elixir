defmodule ImmudbElixirTest do
  use ExUnit.Case
  doctest ImmudbElixir

  test "greets the world" do
    assert ImmudbElixir.hello() == :world
  end
end
