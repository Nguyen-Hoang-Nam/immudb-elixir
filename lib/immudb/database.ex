defmodule Immudb.Database do
  alias Immudb.Util
  alias Immudb.Schema
  alias Immudb.Schema.ImmuService.Stub
  alias Google.Protobuf
  alias Immudb.Socket

  @spec create_database(Socket.t(), binary()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def create_database(%Socket{channel: %GRPC.Channel{} = channel, token: token}, database_name) do
    channel
    |> Stub.create_database(Schema.Database.new(databaseName: database_name),
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

  def create_database(_, _) do
    {:error, :invalid_params}
  end

  @spec list_databases(Socket.t()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def list_databases(%Socket{channel: %GRPC.Channel{} = channel, token: token}) do
    channel
    |> Stub.database_list(Protobuf.Empty.new(), metadata: token |> Util.metadata())
    |> case do
      {:ok, v} ->
        {:ok, v}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def list_database(_) do
    {:error, :invalid_params}
  end

  @spec use_database(Socket.t(), database_name: String.t()) ::
          {:error, String.t()} | {:ok, String.t()}
  def use_database(%Socket{channel: %GRPC.Channel{} = channel, token: token}, database_name) do
    channel
    |> Stub.use_database(Schema.Database.new(databaseName: database_name),
      metadata: token |> Util.metadata()
    )
    |> case do
      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      {:ok, %{token: token}} ->
        {:ok, token}

      _ ->
        {:error, :unknown}
    end
  end

  def use_database(_, _) do
    {:error, :invalid_params}
  end

  def compact_index(channel) do
    channel
    |> Stub.compact_index(Protobuf.Empty.new())
  end

  def change_permission(channel, params) do
    channel
    |> Stub.change_permission(
      Schema.ChangePermissionRequest.new(
        action: params.action,
        username: params.username,
        database: params.database,
        permission: params.permission
      )
    )
  end

  def set_active_user(channel, params) do
    channel
    |> Stub.set_active_user(
      Schema.SetActiveUserRequest.new(
        active: params.active,
        username: params.username
      )
    )
  end
end
