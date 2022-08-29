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

    assert {:ok, %Immudb.TxMetaData{}} =
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

    assert {:ok, %Immudb.VerifiableTx{}} =
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

    assert {:ok, %Immudb.TxMetaData{}} =
             socket
             |> Immudb.set("test_#{:os.system_time(:millisecond)}", "value")

    assert {:ok, v} = socket |> Immudb.get("test_#{:os.system_time(:millisecond)}")
  end
end
