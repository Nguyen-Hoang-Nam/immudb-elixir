defmodule Immudb.Tx do
  use Immudb.Grpc, :schema

  alias Immudb.Socket
  alias Immudb.Util

  @spec tx_by_id(Socket.t(), binary()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def tx_by_id(%Socket{channel: %GRPC.Channel{} = channel, token: token}, tx) do
    channel
    |> Stub.tx_by_id(Schema.TxRequest.new(tx: tx), metadata: token |> Util.metadata())
    |> case do
      {:ok, v} ->
        {:ok, v}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def tx_by_id(_, _) do
    {:error, :invalid_params}
  end

  @spec verifiable_tx_by_id(Socket.t(), binary(), binary()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def verifiable_tx_by_id(
        %Socket{channel: %GRPC.Channel{} = channel, token: token},
        tx,
        prove_since_tx
      ) do
    channel
    |> Stub.verifiable_tx_by_id(
      Schema.VerifiableTxRequest.new(
        tx: tx,
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

  def verifiable_tx_by_id(_, _, _) do
    {:error, :invalid_params}
  end

  @spec use_snapshot(Socket.t(), integer(), integer()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def use_snapshot(
        %Socket{channel: %GRPC.Channel{} = channel, token: token},
        since_tx,
        as_before_tx
      ) do
    channel
    |> Stub.use_snapshot(
      Schema.UseSnapshotRequest.new(
        sinceTx: since_tx,
        asBeforeTx: as_before_tx
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

  def use_snapshot(_, _, _) do
    {:error, :invalid_params}
  end
end
