defmodule Immudb.KV do
  alias Immudb.Socket
  alias Immudb.Util
  alias Immudb.Schema
  alias Immudb.Schema.ImmuService.Stub
  alias Immudb.TxMetaData
  alias Immudb.VerifiableTx
  alias Immudb.Entry

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
  def verifiable_set(%Socket{channel: %GRPC.Channel{} = channel, token: token}, key, value)
      when key |> is_binary() and value |> is_binary() do
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

  @spec get(Socket.t(), binary()) ::
          {:error, String.t() | atom()} | {:ok, Entry.t()}
  def get(%Socket{channel: %GRPC.Channel{} = channel, token: token}, key)
      when key |> is_binary() do
    channel
    |> Stub.get(
      Schema.KeyRequest.new(key: key),
      metadata: token |> Util.metadata()
    )
    |> case do
      {:ok, v} ->
        {:ok, v |> Immudb.Entry.convert()}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def get(_, _) do
    {:error, :invalid_params}
  end

  @spec verifiable_get(Socket.t(), binary()) ::
          {:error, String.t() | atom()} | {:ok, VerifiableTx.t()}
  def verifiable_get(%Socket{channel: %GRPC.Channel{} = channel, token: token}, key)
      when key |> is_binary() do
    channel
    |> Stub.verifiable_get(
      Schema.VerifiableGetRequest.new(keyRequest: Schema.KeyRequest.new(key: key)),
      metadata: token |> Util.metadata()
    )
    |> case do
      {:ok, v} ->
        {:ok, v |> Immudb.VerifiableEntry.convert()}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def verifiable_get(_, _) do
    {:error, :invalid_params}
  end
end
