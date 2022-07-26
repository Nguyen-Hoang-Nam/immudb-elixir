defmodule ImmudbTest do
  use ExUnit.Case

  require Logger

  test "New connection" do
    {ok, _} =
      Immudb.new(
        host: "localhost",
        port: 3322,
        username: "immudb",
        password: "immudb",
        database: "defaultdb"
      )

    assert ok == :ok
  end

  test "New connection 2" do
    {ok, _} = Immudb.new(url: "immudb://immudb:immudb@localhost:3322/defaultdb")

    assert ok == :ok
  end

  test "List users" do
    {ok, immudb} = Immudb.new(url: "immudb://immudb:immudb@localhost:3322/defaultdb")

    assert ok == :ok
  end
end
