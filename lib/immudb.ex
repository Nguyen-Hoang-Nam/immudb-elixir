defmodule Immudb do
  use GRPC.Server, service: Immudb.Schema.ImmuService.Service

  alias Immudb.Schema
  alias Immudb.Schema.ImmuService.Stub
  alias Google.Protobuf
  alias Immudb.Client
  alias Immudb.Socket
  alias Immudb.KV
  alias Immudb.VerifiableTx

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
  def list_users(%Socket{} = socket) do
    socket |> Client.list_users()
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
  def create_user(%Socket{} = socket,
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

  def create_user(_) do
    {:error, :invalid_params}
  end

  @spec change_password(Socket.t(),
          user: String.t(),
          old_password: String.t(),
          new_password: String.t()
        ) ::
          {:error, String.t() | atom()} | {:ok, String.t()}
  def change_password(%Socket{} = socket,
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

  def login(_, _, _) do
    {:error, :invalid_params}
  end

  @spec logout(Socket.t()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def logout(%Socket{} = socket) do
    socket |> Client.logout()
  end

  def logout(_) do
    {:error, :invalid_params}
  end

  @spec set(Socket.t(), binary(), binary()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def set(%Socket{} = socket, key, value)
      when key |> is_binary() and value |> is_binary() do
    socket |> KV.set(key, value)
  end

  def set(_, _, _) do
    {:error, :invalid_params}
  end

  @spec verifiable_set(Socket.t(), binary(), binary()) ::
          {:error, String.t() | atom()} | {:ok, VerifiableTx.t()}
  def verifiable_set(%Socket{} = socket, key, value)
      when key |> is_binary() and value |> is_binary() do
    socket |> KV.verifiable_set(key, value)
  end

  def verifiable_set(_, _, _) do
    {:error, :invalid_params}
  end

  @spec get(Socket.t(), binary()) ::
          {:error, String.t() | atom()} | {:ok, nil}
  def get(%Socket{} = socket, key)
      when key |> is_binary() do
    socket |> KV.get(key)
  end

  def get(_, _) do
    {:error, :invalid_params}
  end

  def verifiable_get(socket, key) do
    with {:ok, response} <-
           socket.channel
           |> Stub.verifiable_get(
             Schema.VerifiableGetRequest.new(keyRequest: Schema.KeyRequest.new(key: key)),
             metadata: metadata(socket)
           ) do
      {:ok, response.entry.value}
    else
      {:error, %GRPC.RPCError{message: message}} -> {:error, message}
    end
  end

  def set_all(socket, params) do
    kvs =
      for {key, value} <- params do
        Schema.KeyValue.new(key: key, value: value)
      end

    with {:ok, _} <-
           socket.channel
           |> Stub.set(
             Schema.SetRequest.new(KVs: kvs),
             metadata: metadata(socket)
           ) do
      :ok
    else
      {:error, %GRPC.RPCError{message: message}} -> {:error, message}
    end
  end

  def get_all(socket, keys) do
    with {:ok, response} <-
           socket.channel
           |> Stub.get_all(
             Schema.KeyListRequest.new(keys: keys),
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

  def exec_all(socket, params) do
    socket.channel
    |> Stub.exec_all(
      Schema.ExecAllRequest.new(
        Operations: Schema.Op.new(nil),
        noWait: params.no_wait
      ),
      metadata: metadata(socket)
    )
  end

  def scan(socket) do
    with {:ok, response} <-
           socket.channel
           |> Stub.scan(
             Schema.ScanRequest.new(
               # seekKey: params.seen_key,
               # prefix: params.prefix,
               # desc: params.desc,
               # limit: params.limit,
               # sinceTx: params.since_tx,
               # noWait: params.no_wait
             ),
             metadata: metadata(socket)
           ) do
      for entri <- response.entries do
        %{tx: entri.tx, value: entri.value, key: entri.key}
      end
    else
      {:error, %GRPC.RPCError{message: message}} -> {:error, message}
    end
  end

  def count(socket, prefix) do
    socket.channel
    |> Stub.count(Schema.KeyPrefix.new(prefix: prefix), metadata: metadata(socket))
  end

  def count_all(socket) do
    socket.channel
    |> Stub.count_all(Protobuf.Empty.new(), metadata: metadata(socket))
  end

  def tx_by_id(socket, params) do
    socket.channel
    |> Stub.tx_by_id(Schema.TxRequest.new(tx: params.tx), metadata: metadata(socket))
  end

  def verifiable_tx_by_id(socket, params) do
    socket.channel
    |> Stub.verifiable_tx_by_id(
      Schema.VerifiableTxRequest.new(
        tx: params.tx,
        proveSinceTx: params.prove_since_tx
      ),
      metadata: metadata(socket)
    )
  end

  def tx_scan(socket, params) do
    socket.channel
    |> Stub.tx_scan(
      Schema.TxScanRequest.new(
        initialTx: params.initial_tx,
        limit: params.limit,
        desc: params.desc
      ),
      metadata: metadata(socket)
    )
  end

  def history(socket, key) do
    with {:ok, response} <-
           socket.channel
           |> Stub.history(
             Schema.HistoryRequest.new(
               key: key
               # offset: params.offset,
               # limit: params.limit,
               # desc: params.desc,
               # sinceTx: params.since_tx
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

  def health(socket) do
    socket.channel
    |> Stub.health(Protobuf.Empty.new())
  end

  def current_state(socket) do
    socket.channel
    |> Stub.current_state(Protobuf.Empty.new(), metadata: metadata(socket))
  end

  def set_reference(channel, params) do
    channel
    |> Stub.set_reference(
      Schema.ReferenceRequest.new(
        key: params.key,
        referencedKey: params.referenced_key,
        atTx: params.at_tx,
        boundRef: params.bound_ref,
        noWait: params.no_wait
      )
    )
  end

  def verifiable_set_reference(channel, params) do
    channel
    |> Stub.verifiable_set_reference(
      Schema.VerifiableReferenceRequest.new(
        referenceRequest:
          Schema.ReferenceRequest.new(
            key: params.key,
            referencedKey: params.referenced_key,
            atTx: params.at_tx,
            boundRef: params.bound_ref,
            noWait: params.no_wait
          ),
        proveSinceTx: params.prove_since_tx
      )
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

  def create_database(socket, database_name) do
    with {:ok, _} <-
           socket.channel
           |> Stub.create_database(Schema.Database.new(databaseName: database_name),
             metadata: metadata(socket)
           ) do
      :ok
    else
      {:error, %GRPC.RPCError{message: message}} -> {:error, message}
    end
  end

  def list_databases(socket) do
    with {:ok, response} <-
           socket.channel
           |> Stub.database_list(Protobuf.Empty.new(), metadata: metadata(socket)) do
      {:ok,
       for database <- response.databases do
         database.databaseName
       end}
    else
      {:error, %GRPC.RPCError{message: message}} -> {:error, message}
    end
  end

  def use_database(socket, database_name) do
    with {:ok, response} <-
           socket.channel
           |> Stub.use_database(Schema.Database.new(databaseName: database_name),
             metadata: metadata(socket)
           ) do
      {:ok, response.token}
    else
      {:error, %GRPC.RPCError{message: message}} -> {:error, message}
    end
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

  def sql_exec(socket, sql) do
    socket.channel
    |> Stub.sql_exec(
      Schema.SQLExecRequest.new(sql: sql),
      metadata: metadata(socket)
    )
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

  def sql_exec(socket, sql, params) do
    with {:ok, _} <-
           socket.channel
           |> Stub.sql_exec(
             Schema.SQLExecRequest.new(
               sql: sql,
               params:
                 for {key, value} <- params do
                   Schema.NamedParam.new(name: Atom.to_string(key), value: sql_value(value))
                 end
             ),
             metadata: metadata(socket)
           ) do
      :ok
    else
      {:error, %GRPC.RPCError{message: message}} -> {:error, message}
    end
  end

  def sql_query(socket, sql, params) do
    with {:ok, response} <-
           socket.channel
           |> Stub.sql_query(
             Schema.SQLQueryRequest.new(
               sql: sql,
               params:
                 for {key, value} <- params do
                   Schema.NamedParam.new(name: Atom.to_string(key), value: sql_value(value))
                 end
             ),
             metadata: metadata(socket)
           ) do
      {:ok, response.rows}
    else
      {:error, %GRPC.RPCError{message: message}} -> {:error, message}
    end
  end

  def list_tables(socket) do
    with {:ok, response} <-
           socket.channel
           |> Stub.list_tables(Protobuf.Empty.new(), metadata: metadata(socket)) do
      {:ok, response}
    else
      {:error, %GRPC.RPCError{message: message}} -> {:error, message}
    end
  end

  def describe_table(socket, table_name) do
    socket.channel
    |> Stub.describe_table(Schema.Table.new(tableName: table_name), metadata: metadata(socket))
  end

  def verifiable_sql_get(socket, params) do
    socket.channel
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
      metadata: metadata(socket)
    )
  end
end
