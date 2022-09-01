defmodule Immudb.StreamTest do
  use ExUnit.Case

  test "Get stream" do
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
             |> Immudb.set("test_#{:os.system_time(:millisecond)}", "value")

    assert {:ok, _} = socket |> Immudb.stream_get(key: key, since_tx: 1)
  end
end
