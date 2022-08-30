defmodule Immudb.KVTest do
  use ExUnit.Case

  require Logger

  test "Set" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    assert {:ok, %Immudb.Schemas.TxMetaData{}} =
             socket
             |> Immudb.set("test_#{:os.system_time(:millisecond)}", "value")
  end

  test "Set with integer value" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    assert {:error, :invalid_params} =
             socket
             |> Immudb.set("test_#{:os.system_time(:millisecond)}", 1)
  end

  test "Verify Set" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    assert {:ok, %Immudb.Schemas.VerifiableTx{}} =
             socket
             |> Immudb.verifiable_set("test_#{:os.system_time(:millisecond)}", "value")
  end

  test "Get" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    key = "test_#{:os.system_time(:millisecond)}"

    assert {:ok, %Immudb.Schemas.TxMetaData{}} =
             socket
             |> Immudb.set(key, "value")

    assert {:ok, %Immudb.Schemas.Entry{}} = socket |> Immudb.get(key)
  end

  test "Verifiable Get" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    key = "test_#{:os.system_time(:millisecond)}"

    assert {:ok, %Immudb.Schemas.TxMetaData{}} =
             socket
             |> Immudb.set(key, "value")

    assert {:ok, %Immudb.Schemas.VerifiableEntry{}} = socket |> Immudb.verifiable_get(key)
  end

  test "Set all" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    assert {:ok, %Immudb.Schemas.TxMetaData{}} =
             socket
             |> Immudb.set_all([
               {"test_1_#{:os.system_time(:millisecond)}", "value 1"},
               {"test_2_#{:os.system_time(:millisecond)}", "value 2"}
             ])
  end

  test "Get all" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    key1 = "test_1_#{:os.system_time(:millisecond)}"
    key2 = "test_2_#{:os.system_time(:millisecond)}"

    assert {:ok, %Immudb.Schemas.TxMetaData{}} =
             socket
             |> Immudb.set_all([
               {key1, "value 1"},
               {key2, "value 2"}
             ])

    assert {:ok, %Immudb.Schemas.Entries{}} = socket |> Immudb.get_all([key1, key2])
  end
end
