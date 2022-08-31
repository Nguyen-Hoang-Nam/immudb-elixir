defmodule Immudb.Stream do
  alias Immudb.Util
  alias Immudb.Schema
  alias Immudb.Schema.ImmuService.Stub
  alias Immudb.Socket

  @spec stream_get(Socket.t(),
          key: String.t(),
          at_tx: integer(),
          since_tx: integer()
        ) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def stream_get(%Socket{channel: %GRPC.Channel{} = channel, token: token},
        key: key,
        at_tx: at_tx,
        since_tx: since_tx
      ) do
    channel
    |> Stub.stream_get(
      Schema.KeyRequest.new(
        key: key,
        atTx: at_tx,
        sinceTx: since_tx
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

  def stream_get(_, _) do
    {:error, :invalid_params}
  end

  def stream_set(_channel, _params) do
  end

  @spec stream_verifiable_get(Socket.t(),
          key: String.t(),
          at_tx: integer(),
          since_tx: integer(),
          prove_since_tx: integer()
        ) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def stream_verifiable_get(%Socket{channel: %GRPC.Channel{} = channel, token: token},
        key: key,
        at_tx: at_tx,
        since_tx: since_tx,
        prove_since_tx: prove_since_tx
      ) do
    channel
    |> Stub.stream_verifiable_get(
      Schema.VerifiableGetRequest.new(
        keyRequest:
          Schema.KeyRequest.new(
            key: key,
            atTx: at_tx,
            sinceTx: since_tx
          ),
        proveSinceTx: prove_since_tx
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

  def stream_verifiable_get(_, _) do
    {:error, :invalid_params}
  end

  def stream_verifiable_set(_channel, _params) do
  end

  @spec stream_scan(Socket.t(),
          seek_key: binary(),
          prefix: binary(),
          desc: binary(),
          limit: integer(),
          since_tx: binary(),
          no_wait: boolean()
        ) ::
          {:error, String.t() | atom()} | {:ok, Entries.t()}
  def stream_scan(%Socket{channel: %GRPC.Channel{} = channel, token: token},
        seek_key: seek_key,
        prefix: prefix,
        desc: desc,
        limit: limit,
        since_tx: since_tx,
        no_wait: no_wait
      ) do
    channel
    |> Stub.stream_scan(
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
        {:ok, v |> Immudb.Schemas.Entries.convert()}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def stream_scan(_, _) do
    {:error, :invalid_params}
  end

  def stream_z_scan(_channel, _params) do
  end

  @spec stream_history(Socket.t(), binary(),
          offset: integer(),
          limit: integer(),
          desc: boolean(),
          since_tx: integer()
        ) ::
          {:error, String.t() | atom()} | {:ok, Immudb.Schemas.Entries.t()}
  def stream_history(%Socket{channel: %GRPC.Channel{} = channel, token: token}, key,
        offset: offset,
        limit: limit,
        desc: desc,
        since_tx: since_tx
      ) do
    channel
    |> Stub.stream_history(
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

  def stream_history(_, _, _) do
    {:error, :invalid_params}
  end

  def stream_exec_all(_channel, _params) do
  end
end
