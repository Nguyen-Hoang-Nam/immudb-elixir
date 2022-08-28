defmodule Immudb.Client do
  alias Immudb.Socket
  alias Immudb.Database
  alias Immudb.Util
  alias Immudb.Schema
  alias Immudb.Schema.ImmuService.Stub
  alias Google.Protobuf
  alias Immudb.User

  @spec connection(String.t(), integer) :: GRPC.Channel.t()
  defp connection(host, port) do
    "#{host}:#{port}"
    |> GRPC.Stub.connect(interceptors: [GRPC.Logger.Client])
  end

  @spec new(
          host: String.t(),
          port: integer(),
          username: String.t(),
          password: String.t(),
          database: String.t()
        ) :: {:ok, Socket.t()} | {:error, String.t()}
  def new(
        host: host,
        port: port,
        username: username,
        password: password,
        database: database
      ) do
    with {:grpc_connect, {:ok, channel}} <-
           {:grpc_connect, connection(host, port)},
         {:immudb_login, {:ok, token}} <-
           {:immudb_login,
            channel
            |> login(username, password)},
         socket <- %Socket{channel: channel, token: token},
         {:immudb_use_database, {:ok, token}} <-
           {:immudb_use_database,
            socket
            |> Database.use_database(database)} do
      {:ok, %Socket{channel: channel, token: token}}
    else
      {:grpc_connect, {:error, e}} ->
        {:error, e}

      {:immudb_login, {:error, e}} ->
        {:error, e}

      {:immudb_use_database, {:error, e}} ->
        {:error, e}
    end
  end

  @spec new(url: String.t()) :: {:ok, Socket.t()} | {:error, String.t()}
  def new(url: url) do
    with {:parse_uri, {:ok, uri}} <- {:parse_uri, URI.new(url)},
         {:is_immudb_schema, true} <- {:is_immudb_schema, uri.scheme == "immudb"},
         userinfo <- uri.userinfo |> String.split(":", trim: true),
         {:is_userinfo, true} <- {:is_userinfo, userinfo |> length > 0} do
      {username, password} =
        userinfo
        |> case do
          [username] -> {username, ""}
          [username, password] -> {username, password}
          _ -> {"", ""}
        end

      new(
        host: uri.host,
        port: uri.port,
        username: username,
        password: password,
        database: uri.path |> String.slice(1, String.length(uri.path) - 1)
      )
    else
      {:parse_uri, {:error, _}} -> {:error, "Invalid connection string"}
      {:is_immudb_schema, false} -> {:error, "Invalid connection string"}
      {:is_userinfo, false} -> {:error, "Invalid user info"}
    end
  end

  def new(_) do
    {:error, :invalid_params}
  end

  @spec list_users(Socket.t()) ::
          {:error, String.t() | atom()} | {:ok, [User.t()]}
  def list_users(%Socket{channel: %GRPC.Channel{} = channel, token: token}) do
    channel
    |> Stub.list_users(Google.Protobuf.Empty.new(), metadata: token |> Util.metadata())
    |> case do
      {:ok, %{users: users}} ->
        {:ok, users |> Immudb.User.convert()}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def list_users(_) do
    {:error, :invalid_params}
  end

  @spec create_user(Socket.t(),
          user: String.t(),
          password: String.t(),
          database: String.t(),
          permission: atom()
        ) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def create_user(%Socket{channel: %GRPC.Channel{} = channel, token: token},
        user: user,
        password: password,
        database: database,
        permission: permission
      ) do
    channel
    |> Stub.create_user(
      Schema.CreateUserRequest.new(
        user: user,
        password: password,
        permission: permission |> Immudb.Permission.to_int(),
        database: database
      ),
      metadata: token |> Util.metadata()
    )
    |> case do
      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      {:ok, %Google.Protobuf.Empty{}} ->
        {:ok, nil}

      _ ->
        {:error, :unknown}
    end
  end

  def create_user(_) do
    {:error, :invalid_params}
  end

  @spec change_password(Socket.t(),
          user: String.t(),
          old_password: String.t(),
          new_password: String.t()
        ) ::
          {:error, String.t() | atom()} | {:ok, String.t()}
  def change_password(%Socket{channel: %GRPC.Channel{} = channel, token: token},
        user: user,
        old_password: old_password,
        new_password: new_password
      ) do
    channel
    |> Stub.change_password(
      Schema.ChangePasswordRequest.new(
        user: user,
        oldPassword: old_password,
        newPassword: new_password
      ),
      metadata: token |> Util.metadata()
    )
    |> case do
      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      {:ok, %Google.Protobuf.Empty{}} ->
        {:ok, nil}

      _ ->
        {:error, :unknown}
    end
  end

  def change_password(_, _) do
    {:error, :invalid_params}
  end

  def update_auth_config(socket, params) do
    socket.channel
    |> Stub.update_auth_config(Schema.AuthConfig.new(kind: params.kind))
  end

  def update_mtls_confg(socket, params) do
    socket.channel
    |> Stub.update_mtls_config(Schema.MTLSConfig.new(enabled: params.enabled))
  end

  @spec login(GRPC.Channel.t(), String.t(), String.t()) ::
          {:error, String.t() | atom()} | {:ok, String.t()}
  def login(%GRPC.Channel{} = channel, user, password) do
    channel
    |> Stub.login(Schema.LoginRequest.new(user: user, password: password))
    |> case do
      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      {:ok, %{token: token}} ->
        {:ok, token}

      _ ->
        {:error, :unknown}
    end
  end

  def login(_, _, _) do
    {:error, :invalid_params}
  end

  @spec logout(GRPC.Channel.t()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def logout(%Socket{channel: %GRPC.Channel{} = channel, token: token}) do
    channel
    |> Stub.logout(Protobuf.Empty.new(), metadata: token |> Util.metadata())
    |> case do
      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      {:ok, %Google.Protobuf.Empty{}} ->
        {:ok, nil}

      _ ->
        {:error, :unknown}
    end
  end

  def logout(_) do
    {:error, :invalid_params}
  end
end
