defmodule Immudb.Database do
  use Immudb.Grpc, :schema

  alias Immudb.Util
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

  @spec compact_index(Socket.t()) ::
          {:error, String.t()} | {:ok, nil}
  def compact_index(%Socket{channel: %GRPC.Channel{} = channel, token: token}) do
    channel
    |> Stub.compact_index(Protobuf.Empty.new(), metadata: token |> Util.metadata())
    |> case do
      {:ok, _} ->
        {:ok, nil}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def compact_index(_, _) do
    {:error, :invalid_params}
  end

  @spec change_permission(Socket.t(),
          action: :GRANT | :REVOKE,
          username: String.t(),
          database: String.t(),
          permission: atom()
        ) ::
          {:error, String.t()} | {:ok, nil}
  def change_permission(%Socket{channel: %GRPC.Channel{} = channel, token: token},
        action: action,
        username: username,
        database: database,
        permission: permission
      ) do
    channel
    |> Stub.change_permission(
      Schema.ChangePermissionRequest.new(
        action: action,
        username: username,
        database: database,
        permission: permission |> Immudb.Schemas.Permission.to_int()
      ),
      metadata: token |> Util.metadata()
    )
    |> case do
      {:ok, _} ->
        {:ok, nil}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def change_permission(_, _) do
    {:error, :invalid_params}
  end

  @spec set_active_user(Socket.t(),
          active: boolean(),
          username: String.t()
        ) ::
          {:error, String.t()} | {:ok, nil}
  def set_active_user(%Socket{channel: %GRPC.Channel{} = channel, token: token},
        active: active,
        username: username
      ) do
    channel
    |> Stub.set_active_user(
      Schema.SetActiveUserRequest.new(
        active: active,
        username: username
      ),
      metadata: token |> Util.metadata()
    )
    |> case do
      {:ok, _} ->
        {:ok, nil}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def set_active_user(_, _) do
    {:error, :invalid_params}
  end
end
