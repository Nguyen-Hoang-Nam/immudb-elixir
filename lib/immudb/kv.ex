defmodule Immudb.KV do
  alias Google.Protobuf
  alias Immudb.Socket
  alias Immudb.Util
  alias Immudb.Schema
  alias Immudb.Schema.ImmuService.Stub
  alias Immudb.Schemas.TxMetaData
  alias Immudb.Schemas.VerifiableTx
  alias Immudb.Schemas.Entry

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
        {:ok, v |> Immudb.Schemas.TxMetaData.convert()}

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
        {:ok, v |> Immudb.Schemas.VerifiableTx.convert()}

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
        {:ok, v |> Immudb.Schemas.Entry.convert()}

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
        {:ok, v |> Immudb.Schemas.VerifiableEntry.convert()}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def verifiable_get(_, _) do
    {:error, :invalid_params}
  end

  @spec set_all(Socket.t(), [{binary(), binary()}]) ::
          {:error, String.t() | atom()} | {:ok, TxMetaData.t()}
  def set_all(%Socket{channel: %GRPC.Channel{} = channel, token: token}, kvs) do
    kvs =
      kvs
      |> Enum.map(fn {key, value} ->
        Schema.KeyValue.new(key: key, value: value)
      end)

    channel
    |> Stub.set(
      Schema.SetRequest.new(KVs: kvs),
      metadata: token |> Util.metadata()
    )
    |> case do
      {:ok, v} ->
        {:ok, v |> Immudb.Schemas.TxMetaData.convert()}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def set_all(_, _) do
    {:error, :invalid_params}
  end

  @spec get_all(Socket.t(), [{binary(), binary()}]) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def get_all(%Socket{channel: %GRPC.Channel{} = channel, token: token}, keys) do
    channel
    |> Stub.get_all(
      Schema.KeyListRequest.new(keys: keys),
      metadata: token |> Util.metadata()
    )
    |> case do
      {:ok, v} ->
        {:ok, v |> Immudb.Schemas.Entries.convert()}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def get_all(_, _) do
    {:error, :invalid_params}
  end

  @spec scan(Socket.t(),
          seek_key: binary(),
          prefix: binary(),
          desc: boolean(),
          limit: integer(),
          since_tx: integer(),
          no_wait: boolean()
        ) ::
          {:error, String.t() | atom()} | {:ok, Immudb.Schemas.EntryCount.t()}
  def scan(%Socket{channel: %GRPC.Channel{} = channel, token: token},
        seek_key: seek_key,
        prefix: prefix,
        desc: desc,
        limit: limit,
        since_tx: since_tx,
        no_wait: no_wait
      ) do
    channel
    |> Stub.scan(
      Schema.ScanRequest.new(
        seekKey: seek_key,
        prefix: prefix,
        desc: desc,
        limit: limit,
        sinceTx: since_tx,
        noWait: no_wait
      ),
      metadata: token |> Util.metadata()
    )
    |> case do
      {:ok, v} ->
        {:ok, v}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def scan(_, _) do
    {:error, :invalid_params}
  end

  @spec count(Socket.t(), [binary()]) ::
          {:error, String.t() | atom()} | {:ok, EntryCount.t()}
  def count(%Socket{channel: %GRPC.Channel{} = channel, token: token}, prefix) do
    channel
    |> Stub.count(Schema.KeyPrefix.new(prefix: prefix), metadata: token |> Util.metadata())
    |> case do
      {:ok, %{count: count}} ->
        {:ok, %Immudb.Schemas.EntryCount{count: count}}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def count(_, _) do
    {:error, :invalid_params}
  end

  @spec count_all(Socket.t()) ::
          {:error, String.t() | atom()} | {:ok, EntryCount.t()}
  def count_all(%Socket{channel: %GRPC.Channel{} = channel, token: token}) do
    channel
    |> Stub.count_all(Protobuf.Empty.new(), metadata: token |> Util.metadata())
    |> case do
      {:ok, %{count: count}} ->
        {:ok, %Immudb.Schemas.EntryCount{count: count}}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def count_all(_) do
    {:error, :invalid_params}
  end

  @spec tx_scan(Socket.t(), initial_tx: integer(), limit: integer(), desc: boolean()) ::
          {:error, String.t() | atom()} | {:ok, Immudb.Schemas.TxList.t()}
  def tx_scan(%Socket{channel: %GRPC.Channel{} = channel, token: token},
        initial_tx: initial_tx,
        limit: limit,
        desc: desc
      ) do
    channel
    |> Stub.tx_scan(
      Schema.TxScanRequest.new(
        initialTx: initial_tx,
        limit: limit,
        desc: desc
      ),
      metadata: token |> Util.metadata()
    )
    |> case do
      {:ok, %{txs: txs}} ->
        {:ok, %Immudb.Schemas.TxList{txs: txs}}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def tx_scan(_, _) do
    {:error, :invalid_params}
  end

  @spec history(Socket.t(), binary(),
          offset: integer(),
          limit: integer(),
          desc: boolean(),
          since_tx: integer()
        ) ::
          {:error, String.t() | atom()} | {:ok, Immudb.Schemas.Entries.t()}
  def history(%Socket{channel: %GRPC.Channel{} = channel, token: token}, key,
        offset: offset,
        limit: limit,
        desc: desc,
        since_tx: since_tx
      ) do
    channel
    |> Stub.history(
      Schema.HistoryRequest.new(
        key: key,
        offset: offset,
        limit: limit,
        desc: desc,
        sinceTx: since_tx
      ),
      metadata: token |> Util.metadata()
    )
    |> case do
      {:ok, v} ->
        {:ok, v |> Immudb.Schemas.Entries.convert()}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def history(_, _, _) do
    {:error, :invalid_params}
  end

  @spec set_reference(Socket.t(),
          key: binary(),
          referenced_key: binary(),
          at_tx: integer(),
          bound_ref: boolean(),
          no_wait: boolean()
        ) ::
          {:error, String.t() | atom()} | {:ok, Immudb.Schemas.TxMetaData.t()}
  def set_reference(%Socket{channel: %GRPC.Channel{} = channel, token: token},
        key: key,
        referenced_key: referenced_key,
        at_tx: at_tx,
        bound_ref: bound_ref,
        no_wait: no_wait
      ) do
    channel
    |> Stub.set_reference(
      Schema.ReferenceRequest.new(
        key: key,
        referencedKey: referenced_key,
        atTx: at_tx,
        boundRef: bound_ref,
        noWait: no_wait
      ),
      metadata: token |> Util.metadata()
    )
    |> case do
      {:ok, v} ->
        {:ok, v |> Immudb.Schemas.TxMetaData.convert()}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def set_reference(_, _) do
    {:error, :invalid_params}
  end
end
