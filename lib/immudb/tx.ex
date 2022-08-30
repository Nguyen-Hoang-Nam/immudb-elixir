defmodule Immudb.Tx do
  alias Immudb.Schema
  alias Immudb.Schema.ImmuService.Stub
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
end
