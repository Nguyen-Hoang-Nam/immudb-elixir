defmodule ImmudbTest do
  use ExUnit.Case

  test "Key value" do
    assert {:ok, immudb} = Immudb.new(url: "immudb://immudb:immudb@localhost:3322/defaultdb")

    assert :ok =
             immudb
             |> Immudb.set("Hello", "World")

    assert {:ok, "World"} =
             immudb
             |> Immudb.get("Hello")

    assert {:ok, "World"} =
             immudb
             |> Immudb.verifiable_get("Hello")

    assert :ok =
             immudb
             |> Immudb.verifiable_set("Hello_1", "World_1")

    assert {:ok, "World_1"} =
             immudb
             |> Immudb.verifiable_get("Hello_1")

    assert {:ok, "World_1"} =
             immudb
             |> Immudb.get("Hello_1")
  end
end
