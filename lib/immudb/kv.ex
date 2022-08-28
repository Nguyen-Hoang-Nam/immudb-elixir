defmodule Immudb.KV do
  alias Immudb.Socket
  alias Immudb.Util
  alias Immudb.Schema
  alias Immudb.Schema.ImmuService.Stub
  alias Immudb.TxMetaData
  alias Immudb.VerifiableTx

  @spec set(Socket.t(), binary(), binary()) ::
          {:error, String.t() | atom()} | {:ok, TxMetaData.t()}
  def set(%Socket{channel: %GRPC.Channel{} = channel, token: token}, key, value)
      when key |> is_binary() and value |> is_binary() do
    channel
    |> Stub.set(
      Schema.SetRequest.new(KVs: [Schema.KeyValue.new(key: key, value: value)]),
      metadata: token |> Util.metadata()
    )
    |> case do
      {:ok, v} ->
        {:ok, v |> Immudb.TxMetaData.convert()}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def set(_, _, _) do
    {:error, :invalid_params}
  end

  @spec verifiable_set(Socket.t(), binary(), binary()) ::
          {:error, String.t() | atom()} | {:ok, VerifiableTx.t()}
  def verifiable_set(%Socket{channel: %GRPC.Channel{} = channel, token: token}, key, value) do
    channel
    |> Stub.verifiable_set(
      Schema.VerifiableSetRequest.new(
        setRequest: Schema.SetRequest.new(KVs: [Schema.KeyValue.new(key: key, value: value)])
      ),
      metadata: token |> Util.metadata()
    )
    |> case do
      {:ok, v} ->
        {:ok, v |> Immudb.VerifiableTx.convert()}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def verifiable_set(_, _, _) do
    {:error, :invalid_params}
  end
end
