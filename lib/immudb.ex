defmodule Immudb do
  use GRPC.Server, service: Immudb.Schema.ImmuService.Service

  alias Immudb.Schema
  alias Immudb.Schema.ImmuService.Stub
  alias Google.Protobuf
  alias Immudb.Client
  alias Immudb.Socket
  alias Immudb.KV
  alias Immudb.Tx
  alias Immudb.Schemas.VerifiableTx
  alias Immudb.Schemas.Entry
  alias Immudb.Schemas.VerifiableEntry
  alias Immudb.Schemas.TxMetaData
  alias Immudb.Util
  alias Immudb.Database
  alias Immudb.Sql
  alias Immudb.Schemas.Entries
  alias Immudb.Schemas.EntryCount

  @spec new(url: String.t()) :: {:ok, Socket.t()} | {:error, String.t()}
  @spec new(
          host: String.t(),
          port: integer(),
          username: String.t(),
          password: String.t(),
          database: String.t()
        ) :: {:ok, Socket.t()} | {:error, String.t()}
  def new(v) do
    v |> Client.new()
  end

  defp metadata(socket) do
    %{authorization: "Bearer #{socket.token}", content_type: "application/grpc"}
  end

  @spec list_users(Socket.t()) ::
          {:error, String.t() | atom()} | {:ok, [User.t()]}
  def list_users(socket) do
    socket |> Client.list_users()
  end

  @spec create_user(Socket.t(),
          user: String.t(),
          password: String.t(),
          database: String.t(),
          permission: atom()
        ) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def create_user(socket,
        user: user,
        password: password,
        database: database,
        permission: permission
      ) do
    socket
    |> Client.create_user(
      user: user,
      password: password,
      database: database,
      permission: permission
    )
  end

  @spec change_password(Socket.t(),
          user: String.t(),
          old_password: String.t(),
          new_password: String.t()
        ) ::
          {:error, String.t() | atom()} | {:ok, String.t()}
  def change_password(socket,
        user: user,
        old_password: old_password,
        new_password: new_password
      ) do
    socket
    |> Client.change_password(
      user: user,
      old_password: old_password,
      new_password: new_password
    )
  end

  def update_auth_config(%Socket{} = socket, v) do
    socket |> Client.update_auth_config(v)
  end

  def update_mtls_confg(%Socket{} = socket, v) do
    socket |> Client.update_mtls_confg(v)
  end

  @spec login(Socket.t(), String.t(), String.t()) ::
          {:error, String.t() | atom()} | {:ok, String.t()}
  def login(%Socket{channel: %GRPC.Channel{} = channel}, user, password) do
    channel |> Client.login(user, password)
  end

  @spec logout(Socket.t()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def logout(socket) do
    socket |> Client.logout()
  end

  @spec set(Socket.t(), binary(), binary()) ::
          {:error, String.t() | atom()} | {:ok, TxMetaData.t()}
  def set(socket, key, value) do
    socket |> KV.set(key, value)
  end

  @spec verifiable_set(Socket.t(), binary(), binary()) ::
          {:error, String.t() | atom()} | {:ok, VerifiableTx.t()}
  def verifiable_set(socket, key, value) do
    socket |> KV.verifiable_set(key, value)
  end

  @spec get(Socket.t(), binary()) ::
          {:error, String.t() | atom()} | {:ok, Entry.t()}
  def get(socket, key) do
    socket |> KV.get(key)
  end

  @spec verifiable_get(Socket.t(), binary()) ::
          {:error, String.t() | atom()} | {:ok, VerifiableEntry.t()}
  def verifiable_get(socket, key) do
    socket |> KV.verifiable_get(key)
  end

  @spec set_all(Socket.t(), [{binary(), binary()}]) ::
          {:error, String.t() | atom()} | {:ok, TxMetaData.t()}
  def set_all(socket, kvs) do
    socket |> KV.set_all(kvs)
  end

  @spec get_all(Socket.t(), [binary()]) ::
          {:error, String.t() | atom()} | {:ok, Entries.t()}
  def get_all(socket, keys) do
    socket |> KV.get_all(keys)
  end

  # def exec_all(socket, params) do
  #   socket.channel
  #   |> Stub.exec_all(
  #     Schema.ExecAllRequest.new(
  #       Operations: Schema.Op.new(nil),
  #       noWait: params.no_wait
  #     ),
  #     metadata: metadata(socket)
  #   )
  # end

  @spec scan(Socket.t(),
          seek_key: binary(),
          prefix: binary(),
          desc: binary(),
          limit: integer(),
          since_tx: binary(),
          no_wait: boolean()
        ) ::
          {:error, String.t() | atom()} | {:ok, Entries.t()}
  def scan(socket,
        seek_key: seek_key,
        prefix: prefix,
        desc: desc,
        limit: limit,
        since_tx: since_tx,
        no_wait: no_wait
      ) do
    socket
    |> KV.scan(
      seek_key: seek_key,
      prefix: prefix,
      desc: desc,
      limit: limit,
      since_tx: since_tx,
      no_wait: no_wait
    )
  end

  @spec count(Socket.t(), [binary()]) ::
          {:error, String.t() | atom()} | {:ok, EntryCount.t()}
  def count(socket, prefix) do
    socket |> KV.count(prefix)
  end

  @spec count_all(Socket.t()) ::
          {:error, String.t() | atom()} | {:ok, EntryCount.t()}
  def count_all(socket) do
    socket |> KV.count_all()
  end

  @spec tx_by_id(Socket.t(), binary()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def tx_by_id(socket, tx) do
    socket |> Tx.tx_by_id(tx)
  end

  @spec verifiable_tx_by_id(Socket.t(), binary(), binary()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def verifiable_tx_by_id(socket, tx, prove_since_tx) do
    socket |> Tx.verifiable_tx_by_id(tx, prove_since_tx)
  end

  @spec tx_scan(Socket.t(), initial_tx: integer(), limit: integer(), desc: boolean()) ::
          {:error, String.t() | atom()} | {:ok, Immudb.Schemas.TxList.t()}
  def tx_scan(socket, initial_tx: initial_tx, limit: limit, desc: desc) do
    socket |> KV.tx_scan(initial_tx: initial_tx, limit: limit, desc: desc)
  end

  @spec history(Socket.t(), binary(),
          offset: integer(),
          limit: integer(),
          desc: boolean(),
          since_tx: integer()
        ) ::
          {:error, String.t() | atom()} | {:ok, Immudb.Schemas.Entries.t()}
  def history(socket, key,
        offset: offset,
        limit: limit,
        desc: desc,
        since_tx: since_tx
      ) do
    with {:ok, response} <-
           socket.channel
           |> Stub.history(
             Schema.HistoryRequest.new(
               key: key,
               offset: offset,
               limit: limit,
               desc: desc,
               sinceTx: since_tx
             ),
             metadata: metadata(socket)
           ) do
      {:ok,
       for entri <- response.entries do
         %{tx: entri.tx, value: entri.value}
       end}
    else
      {:error, %GRPC.RPCError{message: message}} -> {:error, message}
    end
  end

  @spec health(Socket.t()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def health(%Socket{channel: %GRPC.Channel{} = channel}) do
    channel
    |> Stub.health(Protobuf.Empty.new())
    |> case do
      {:ok, v} ->
        {:ok, v}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def health(_) do
    {:error, :invalid_params}
  end

  @spec current_state(Socket.t()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def current_state(%Socket{channel: %GRPC.Channel{} = channel, token: token}) do
    channel
    |> Stub.current_state(Protobuf.Empty.new(), metadata: token |> Util.metadata())
    |> case do
      {:ok, v} ->
        {:ok, v}

      {:error, %GRPC.RPCError{message: message}} ->
        {:error, message}

      _ ->
        {:error, :unknown}
    end
  end

  def current_state(_) do
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
  def set_reference(socket,
        key: key,
        referenced_key: referenced_key,
        at_tx: at_tx,
        bound_ref: bound_ref,
        no_wait: no_wait
      ) do
    socket
    |> KV.set_reference(
      key: key,
      referenced_key: referenced_key,
      at_tx: at_tx,
      bound_ref: bound_ref,
      no_wait: no_wait
    )
  end

  @spec set_reference(Socket.t(),
          key: binary(),
          referenced_key: binary(),
          at_tx: integer(),
          bound_ref: boolean(),
          no_wait: boolean(),
          prove_since_tx: integer()
        ) ::
          {:error, String.t() | atom()} | {:ok, Immudb.Schemas.VerifiableTx.t()}
  def verifiable_set_reference(socket,
        key: key,
        referenced_key: referenced_key,
        at_tx: at_tx,
        bound_ref: bound_ref,
        no_wait: no_wait,
        prove_since_tx: prove_since_tx
      ) do
    socket
    |> KV.verifiable_set_reference(
      key: key,
      referenced_key: referenced_key,
      at_tx: at_tx,
      bound_ref: bound_ref,
      no_wait: no_wait,
      prove_since_tx: prove_since_tx
    )
  end

  def z_add(channel, params) do
    channel
    |> Stub.z_add(
      Schema.ZAddRequest.new(
        set: params.set,
        score: params.score,
        key: params.key,
        atTx: params.at_tx,
        boundRef: params.bound_ref,
        noWait: params.no_wait
      )
    )
  end

  def verifiable_z_add(channel, params) do
    channel
    |> Stub.verifiable_z_add(
      Schema.VerifiableZAddRequest.new(
        zAddRequest:
          Schema.ZAddRequest.new(
            set: params.set,
            score: params.score,
            key: params.key,
            atTx: params.at_tx,
            boundRef: params.bound_ref,
            noWait: params.no_wait
          ),
        proveSinceTx: params.prove_since_tx
      )
    )
  end

  def z_scan(channel, params) do
    channel
    |> Stub.z_scan(
      Schema.ZScanRequest.new(
        set: params.set,
        seekKey: params.seek_key,
        seekScore: params.seek_score,
        seekAtTx: params.seek_at_tx,
        inclusiveSeek: params.inclusive_seek,
        limit: params.limit,
        desc: params.desc,
        minScore: params.min_score,
        maxScore: params.max_score,
        sinceTx: params.since_tx,
        noWait: params.no_wait
      )
    )
  end

  @spec create_database(Socket.t(), binary()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def create_database(%Socket{} = socket, database_name) do
    socket |> Database.create_database(database_name)
  end

  def create_database(_, _) do
    {:error, :invalid_params}
  end

  @spec list_databases(Socket.t()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def list_databases(%Socket{} = socket) do
    socket |> Database.list_database()
  end

  def list_database(_) do
    {:error, :invalid_params}
  end

  @spec use_database(Socket.t(), database_name: String.t()) ::
          {:error, String.t()} | {:ok, String.t()}
  def use_database(%Socket{} = socket, database_name) do
    socket |> Database.use_database(database_name)
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

  def stream_get(channel, params) do
    channel
    |> Stub.stream_get(
      Schema.KeyRequest.new(
        key: params.key,
        atTx: params.at_tx,
        sinceTx: params.since_tx
      )
    )
  end

  def stream_set(_channel, _params) do
  end

  def stream_verifiable_get(_channel, _params) do
  end

  def stream_verifiable_set(_channel, _params) do
  end

  def stream_scan(_channel, _params) do
  end

  def stream_z_scan(_channel, _params) do
  end

  def stream_history(_channel, _params) do
  end

  def stream_exec_all(_channel, _params) do
  end

  def use_snapshot(channel, params) do
    channel
    |> Stub.use_snapshot(
      Schema.UseSnapshotRequest.new(
        sinceTx: params.since_tx,
        asBeforeTx: params.as_before_tx
      )
    )
  end

  @spec sql_exec(Socket.t(), String.t()) ::
          {:error, String.t()} | {:ok, nil}
  def sql_exec(%Socket{} = socket, sql) do
    socket |> Sql.sql_exec(sql)
  end

  def sql_exec(_, _) do
    {:error, :invalid_params}
  end

  @spec sql_exec(Socket.t(), String.t(), [{String.t(), String.t()}]) ::
          {:error, String.t()} | {:ok, nil}
  def sql_exec(%Socket{} = socket, sql, kvs) do
    socket |> Sql.sql_exec(sql, kvs)
  end

  def sql_exec(_, _, _) do
    {:error, :invalid_params}
  end

  @spec sql_query(Socket.t(), String.t(), [{String.t(), String.t()}]) ::
          {:error, String.t()} | {:ok, nil}
  def sql_query(%Socket{} = socket, sql, kvs) do
    socket |> Sql.sql_query(sql, kvs)
  end

  def sql_query(_, _, _) do
    {:error, :invalid_params}
  end

  @spec list_tables(Socket.t()) ::
          {:error, String.t()} | {:ok, nil}
  def list_tables(%Socket{} = socket) do
    socket |> Sql.list_tables()
  end

  def list_tables(_) do
    {:error, :invalid_params}
  end

  @spec describe_table(Socket.t(), String.t()) ::
          {:error, String.t()} | {:ok, nil}
  def describe_table(%Socket{} = socket, table_name) do
    socket |> Sql.describe_table(table_name)
  end

  def describe_table(_, _) do
    {:error, :invalid_params}
  end

  @spec verifiable_sql_get(Socket.t(), map()) ::
          {:error, String.t()} | {:ok, nil}
  def verifiable_sql_get(%Socket{} = socket, params) do
    socket |> Sql.verifiable_sql_get(params)
  end

  def verifiable_sql_get(_, _) do
    {:error, :invalid_params}
  end
end
