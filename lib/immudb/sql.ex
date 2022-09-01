defmodule Immudb.Sql do
  use Immudb.Grpc, :schema

  alias Immudb.Socket
  alias Immudb.Util

  @spec sql_exec(Socket.t(), String.t()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def sql_exec(%Socket{channel: %GRPC.Channel{} = channel, token: token}, sql) do
    channel
    |> Stub.sql_exec(
      Schema.SQLExecRequest.new(sql: sql),
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

  def sql_exec(_, _) do
    {:error, :invalid_params}
  end

  defp sql_value(value) when is_nil(value) do
    Schema.SQLValue.new(value: {:null, Protobuf.NullValue})
  end

  defp sql_value(value) when is_number(value) do
    Schema.SQLValue.new(value: {:n, value})
  end

  defp sql_value(value) when is_binary(value) do
    Schema.SQLValue.new(value: {:s, value})
  end

  defp sql_value(value) when is_boolean(value) do
    Schema.SQLValue.new(value: {:b, value})
  end

  defp sql_value(value) when is_bitstring(value) do
    Schema.SQLValue.new(value: {:bs, value})
  end

  @spec sql_exec(Socket.t(), String.t(), [{String.t(), String.t()}]) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def sql_exec(%Socket{channel: %GRPC.Channel{} = channel, token: token}, sql, kvs) do
    channel
    |> Stub.sql_exec(
      Schema.SQLExecRequest.new(
        sql: sql,
        params:
          kvs
          |> Enum.map(fn {key, value} ->
            Schema.NamedParam.new(name: Atom.to_string(key), value: sql_value(value))
          end)
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

  def sql_exec(_, _, _) do
    {:error, :invalid_params}
  end

  @spec sql_query(Socket.t(), String.t(), [{String.t(), String.t()}]) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def sql_query(%Socket{channel: %GRPC.Channel{} = channel, token: token}, sql, kvs) do
    channel
    |> Stub.sql_query(
      Schema.SQLQueryRequest.new(
        sql: sql,
        params:
          kvs
          |> Enum.map(fn {key, value} ->
            Schema.NamedParam.new(name: Atom.to_string(key), value: sql_value(value))
          end)
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

  def sql_query(_, _, _) do
    {:error, :invalid_params}
  end

  @spec list_tables(Socket.t()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def list_tables(%Socket{channel: %GRPC.Channel{} = channel, token: token}) do
    channel
    |> Stub.list_tables(Protobuf.Empty.new(), metadata: token |> Util.metadata())
    |> case do
      {:ok, v} ->
        {:ok, v}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def list_tables(_) do
    {:error, :invalid_params}
  end

  @spec describe_table(Socket.t(), String.t()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def describe_table(%Socket{channel: %GRPC.Channel{} = channel, token: token}, table_name) do
    channel
    |> Stub.describe_table(Schema.Table.new(tableName: table_name),
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

  def describe_table(_, _) do
    {:error, :invalid_params}
  end

  def verifiable_sql_get(%Socket{channel: %GRPC.Channel{} = channel, token: token}, params) do
    channel
    |> Stub.verifiable_sql_get(
      Schema.VerifiableSQLGetRequest.new(
        sqlGetRequest:
          Schema.SQLGetRequest.new(
            table: params.table,
            pkValue: Schema.SQLValue.new(nil),
            atTx: params.at_tx,
            sinceTx: params.since_tx
          ),
        proveSinceTx: params.prove_since_tx
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

  def verifiable_sql_get(_, _) do
    {:error, :invalid_params}
  end
end
