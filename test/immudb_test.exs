defmodule ImmudbTest do
  use ExUnit.Case

  require Logger

  test "New connection" do
    assert {:ok, _} =
      Immudb.new(
        host: "localhost",
        port: 3322,
        username: "immudb",
        password: "immudb",
        database: "defaultdb"
      )
  end

  test "New connection 2" do
    assert {:ok, _} = Immudb.new(url: "immudb://immudb:immudb@localhost:3322/defaultdb")
  end

  test "List users" do
    assert {:ok, immudb} = Immudb.new(url: "immudb://immudb:immudb@localhost:3322/defaultdb")

		assert {:ok, _} = immudb
		|> Immudb.list_users()
  end

	test "Key value" do
		assert {:ok, immudb} = Immudb.new(url: "immudb://immudb:immudb@localhost:3322/defaultdb")

		assert :ok = immudb
		|> Immudb.set("Hello", "World")

		assert {:ok, "World"} = immudb
		|> Immudb.get("Hello")

		assert {:ok, "World"} = immudb
		|> Immudb.verifiable_get("Hello")

		assert :ok = immudb
		|> Immudb.verifiable_set("Hello_1", "World_1")

		assert {:ok, "World_1"} = immudb
		|> Immudb.verifiable_get("Hello_1")

		assert {:ok, "World_1"} = immudb
		|> Immudb.get("Hello_1")
	end

	# test "Create user" do
	# 	assert {:ok, immudb} = Immudb.new(url: "immudb://immudb:immudb@localhost:3322/defaultdb")

	# 	immudb.channel
	# 	|> Immudb.login("immudb", "immudb")
	# 	|> inspect()
	# 	|> Logger.error()
	# end

	# test "Count all" do
	# 	assert {:ok, immudb} = Immudb.new(url: "immudb://immudb:immudb@localhost:3322/defaultdb")

	# 	immudb
	# 	|> Immudb.count_all()
	# 	|> inspect()
	# 	|> Logger.error()
	# end
end
