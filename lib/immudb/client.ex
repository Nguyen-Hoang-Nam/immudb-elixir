defmodule Immudb.Client do
  alias Immudb.Socket
  alias Immudb.Database
  alias Immudb.Util
  alias Immudb.Schema
  alias Immudb.Schema.ImmuService.Stub
  alias Google.Protobuf

  @spec connection(String.t(), integer) :: GRPC.Channel.t()
  defp connection(host, port) do
    "#{host}:#{port}"
    |> GRPC.Stub.connect(interceptors: [GRPC.Logger.Client])
  end

  def new(
        host: host,
        port: port,
        username: username,
        password: password,
        database: database
      ) do
    with {:grpc_connect, {:ok, channel}} <-
           {:grpc_connect, connection(host, port)},
         {:immudb_login, {:ok, response}} <-
           {:immudb_login,
            channel
            |> login(username, password)},
         socket <- %Socket{channel: channel, token: response.token},
         {:immudb_use_database, {:ok, token}} <-
           {:immudb_use_database,
            socket
            |> Database.use_database(database)} do
      {:ok, %Socket{channel: channel, token: token}}
    else
      {:grpc_connect, {:error, _}} -> {:error, "Cannot connect to immudb"}
      {:immudb_login, {:error, _}} -> {:error, "Cannot login to immudb"}
      {:immudb_use_database, {:error, _}} -> {:error, "Cannot use database in immudb"}
    end
  end

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
    {:error, "Missing params"}
  end

  def list_users(socket) do
    with {:ok, response} <-
           socket.channel
           |> Stub.list_users(Google.Protobuf.Empty.new(), metadata: Util.metadata(socket)) do
      {:ok,
       for user <- response.users do
         %{user: user.user}
       end}
    else
      {:error, _} -> "Cannot list users"
    end
  end

  def create_user(socket, params) do
    socket.channel
    |> Stub.create_user(
      Schema.CreateUserRequest.new(
        user: params.user,
        password: params.password,
        permission: params.permission,
        database: params.database
      )
    )
  end

  def change_password(socket, %{
        user: user,
        old_password: old_password,
        new_password: new_password
      }) do
    socket.channel
    |> Stub.change_password(
      Schema.ChangePasswordRequest.new(
        user: user,
        oldPassword: old_password,
        newPassword: new_password
      )
    )
  end

  def change_password(_, _) do
    {:error, "Missing params"}
  end

  def update_auth_config(socket, params) do
    socket.channel
    |> Stub.update_auth_config(Schema.AuthConfig.new(kind: params.kind))
  end

  def update_mtls_confg(socket, params) do
    socket.channel
    |> Stub.update_mtls_config(Schema.MTLSConfig.new(enabled: params.enabled))
  end

  def login(channel, user, password) do
    channel
    |> Stub.login(Schema.LoginRequest.new(user: user, password: password))
  end

  def logout(socket) do
    socket.channel
    |> Stub.logout(Protobuf.Empty.new(), metadata: Util.metadata(socket))
  end
end
