defmodule Immudb.TxTest do
  use ExUnit.Case

  require Logger

  test "Tx" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    assert {:ok, v} =
             socket
             |> Immudb.tx_by_id("")

    v |> inspect() |> Logger.error()
  end

  test "Tx with wrong id" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    assert {:ok, v} =
             socket
             |> Immudb.tx_by_id("1000")

    v |> inspect() |> Logger.error()
  end

  test "Verifiable Tx" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    assert {:ok, v} =
             socket
             |> Immudb.verifiable_tx_by_id("", "")

    v |> inspect() |> Logger.error()
  end
end
