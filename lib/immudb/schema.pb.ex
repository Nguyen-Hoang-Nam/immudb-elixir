defmodule Immudb.Schema.PermissionAction do
  @moduledoc false
  use Protobuf, enum: true, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:GRANT, 0)
  field(:REVOKE, 1)
end

defmodule Immudb.Schema.Key do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:key, 1, type: :bytes)
end

defmodule Immudb.Schema.Permission do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:database, 1, type: :string)
  field(:permission, 2, type: :uint32)
end

defmodule Immudb.Schema.User do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:user, 1, type: :bytes)
  field(:permissions, 3, repeated: true, type: Immudb.Schema.Permission)
  field(:createdby, 4, type: :string)
  field(:createdat, 5, type: :string)
  field(:active, 6, type: :bool)
end

defmodule Immudb.Schema.UserList do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:users, 1, repeated: true, type: Immudb.Schema.User)
end

defmodule Immudb.Schema.CreateUserRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:user, 1, type: :bytes)
  field(:password, 2, type: :bytes)
  field(:permission, 3, type: :uint32)
  field(:database, 4, type: :string)
end

defmodule Immudb.Schema.UserRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:user, 1, type: :bytes)
end

defmodule Immudb.Schema.ChangePasswordRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:user, 1, type: :bytes)
  field(:oldPassword, 2, type: :bytes)
  field(:newPassword, 3, type: :bytes)
end

defmodule Immudb.Schema.LoginRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:user, 1, type: :bytes)
  field(:password, 2, type: :bytes)
end

defmodule Immudb.Schema.LoginResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:token, 1, type: :string)
  field(:warning, 2, type: :bytes)
end

defmodule Immudb.Schema.AuthConfig do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:kind, 1, type: :uint32)
end

defmodule Immudb.Schema.MTLSConfig do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:enabled, 1, type: :bool)
end

defmodule Immudb.Schema.KeyValue do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:key, 1, type: :bytes)
  field(:value, 2, type: :bytes)
end

defmodule Immudb.Schema.Entry do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:tx, 1, type: :uint64)
  field(:key, 2, type: :bytes)
  field(:value, 3, type: :bytes)
  field(:referencedBy, 4, type: Immudb.Schema.Reference)
end

defmodule Immudb.Schema.Reference do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:tx, 1, type: :uint64)
  field(:key, 2, type: :bytes)
  field(:atTx, 3, type: :uint64)
end

defmodule Immudb.Schema.Op do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  oneof(:operation, 0)

  field(:kv, 1, type: Immudb.Schema.KeyValue, oneof: 0)
  field(:zAdd, 2, type: Immudb.Schema.ZAddRequest, oneof: 0)
  field(:ref, 3, type: Immudb.Schema.ReferenceRequest, oneof: 0)
end

defmodule Immudb.Schema.ExecAllRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:Operations, 1, repeated: true, type: Immudb.Schema.Op)
  field(:noWait, 2, type: :bool)
end

defmodule Immudb.Schema.Entries do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:entries, 1, repeated: true, type: Immudb.Schema.Entry)
end

defmodule Immudb.Schema.ZEntry do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:set, 1, type: :bytes)
  field(:key, 2, type: :bytes)
  field(:entry, 3, type: Immudb.Schema.Entry)
  field(:score, 4, type: :double)
  field(:atTx, 5, type: :uint64)
end

defmodule Immudb.Schema.ZEntries do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:entries, 1, repeated: true, type: Immudb.Schema.ZEntry)
end

defmodule Immudb.Schema.ScanRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:seekKey, 1, type: :bytes)
  field(:prefix, 2, type: :bytes)
  field(:desc, 3, type: :bool)
  field(:limit, 4, type: :uint64)
  field(:sinceTx, 5, type: :uint64)
  field(:noWait, 6, type: :bool)
end

defmodule Immudb.Schema.KeyPrefix do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:prefix, 1, type: :bytes)
end

defmodule Immudb.Schema.EntryCount do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:count, 1, type: :uint64)
end

defmodule Immudb.Schema.Signature do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:publicKey, 1, type: :bytes)
  field(:signature, 2, type: :bytes)
end

defmodule Immudb.Schema.TxMetadata do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:id, 1, type: :uint64)
  field(:prevAlh, 2, type: :bytes)
  field(:ts, 3, type: :int64)
  field(:nentries, 4, type: :int32)
  field(:eH, 5, type: :bytes)
  field(:blTxId, 6, type: :uint64)
  field(:blRoot, 7, type: :bytes)
end

defmodule Immudb.Schema.LinearProof do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:sourceTxId, 1, type: :uint64)
  field(:TargetTxId, 2, type: :uint64)
  field(:terms, 3, repeated: true, type: :bytes)
end

defmodule Immudb.Schema.DualProof do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:sourceTxMetadata, 1, type: Immudb.Schema.TxMetadata)
  field(:targetTxMetadata, 2, type: Immudb.Schema.TxMetadata)
  field(:inclusionProof, 3, repeated: true, type: :bytes)
  field(:consistencyProof, 4, repeated: true, type: :bytes)
  field(:targetBlTxAlh, 5, type: :bytes)
  field(:lastInclusionProof, 6, repeated: true, type: :bytes)
  field(:linearProof, 7, type: Immudb.Schema.LinearProof)
end

defmodule Immudb.Schema.Tx do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:metadata, 1, type: Immudb.Schema.TxMetadata)
  field(:entries, 2, repeated: true, type: Immudb.Schema.TxEntry)
end

defmodule Immudb.Schema.TxEntry do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:key, 1, type: :bytes)
  field(:hValue, 2, type: :bytes)
  field(:vOff, 3, type: :int64)
  field(:vLen, 4, type: :int32)
end

defmodule Immudb.Schema.VerifiableTx do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:tx, 1, type: Immudb.Schema.Tx)
  field(:dualProof, 2, type: Immudb.Schema.DualProof)
  field(:signature, 3, type: Immudb.Schema.Signature)
end

defmodule Immudb.Schema.VerifiableEntry do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:entry, 1, type: Immudb.Schema.Entry)
  field(:verifiableTx, 2, type: Immudb.Schema.VerifiableTx)
  field(:inclusionProof, 3, type: Immudb.Schema.InclusionProof)
end

defmodule Immudb.Schema.InclusionProof do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:leaf, 1, type: :int32)
  field(:width, 2, type: :int32)
  field(:terms, 3, repeated: true, type: :bytes)
end

defmodule Immudb.Schema.SetRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:KVs, 1, repeated: true, type: Immudb.Schema.KeyValue)
  field(:noWait, 2, type: :bool)
end

defmodule Immudb.Schema.KeyRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:key, 1, type: :bytes)
  field(:atTx, 2, type: :uint64)
  field(:sinceTx, 3, type: :uint64)
end

defmodule Immudb.Schema.KeyListRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:keys, 1, repeated: true, type: :bytes)
  field(:sinceTx, 2, type: :uint64)
end

defmodule Immudb.Schema.VerifiableSetRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:setRequest, 1, type: Immudb.Schema.SetRequest)
  field(:proveSinceTx, 2, type: :uint64)
end

defmodule Immudb.Schema.VerifiableGetRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:keyRequest, 1, type: Immudb.Schema.KeyRequest)
  field(:proveSinceTx, 2, type: :uint64)
end

defmodule Immudb.Schema.HealthResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:status, 1, type: :bool)
  field(:version, 2, type: :string)
end

defmodule Immudb.Schema.ImmutableState do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:db, 1, type: :string)
  field(:txId, 2, type: :uint64)
  field(:txHash, 3, type: :bytes)
  field(:signature, 4, type: Immudb.Schema.Signature)
end

defmodule Immudb.Schema.ReferenceRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:key, 1, type: :bytes)
  field(:referencedKey, 2, type: :bytes)
  field(:atTx, 3, type: :uint64)
  field(:boundRef, 4, type: :bool)
  field(:noWait, 5, type: :bool)
end

defmodule Immudb.Schema.VerifiableReferenceRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:referenceRequest, 1, type: Immudb.Schema.ReferenceRequest)
  field(:proveSinceTx, 2, type: :uint64)
end

defmodule Immudb.Schema.ZAddRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:set, 1, type: :bytes)
  field(:score, 2, type: :double)
  field(:key, 3, type: :bytes)
  field(:atTx, 4, type: :uint64)
  field(:boundRef, 5, type: :bool)
  field(:noWait, 6, type: :bool)
end

defmodule Immudb.Schema.Score do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:score, 1, type: :double)
end

defmodule Immudb.Schema.ZScanRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:set, 1, type: :bytes)
  field(:seekKey, 2, type: :bytes)
  field(:seekScore, 3, type: :double)
  field(:seekAtTx, 4, type: :uint64)
  field(:inclusiveSeek, 5, type: :bool)
  field(:limit, 6, type: :uint64)
  field(:desc, 7, type: :bool)
  field(:minScore, 8, type: Immudb.Schema.Score)
  field(:maxScore, 9, type: Immudb.Schema.Score)
  field(:sinceTx, 10, type: :uint64)
  field(:noWait, 11, type: :bool)
end

defmodule Immudb.Schema.HistoryRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:key, 1, type: :bytes)
  field(:offset, 2, type: :uint64)
  field(:limit, 3, type: :int32)
  field(:desc, 4, type: :bool)
  field(:sinceTx, 5, type: :uint64)
end

defmodule Immudb.Schema.VerifiableZAddRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:zAddRequest, 1, type: Immudb.Schema.ZAddRequest)
  field(:proveSinceTx, 2, type: :uint64)
end

defmodule Immudb.Schema.TxRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:tx, 1, type: :uint64)
end

defmodule Immudb.Schema.VerifiableTxRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:tx, 1, type: :uint64)
  field(:proveSinceTx, 2, type: :uint64)
end

defmodule Immudb.Schema.TxScanRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:initialTx, 1, type: :uint64)
  field(:limit, 2, type: :uint32)
  field(:desc, 3, type: :bool)
end

defmodule Immudb.Schema.TxList do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:txs, 1, repeated: true, type: Immudb.Schema.Tx)
end

defmodule Immudb.Schema.Database do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:databaseName, 1, type: :string)
end

defmodule Immudb.Schema.Table do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:tableName, 1, type: :string)
end

defmodule Immudb.Schema.SQLGetRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:table, 1, type: :string)
  field(:pkValue, 2, type: Immudb.Schema.SQLValue)
  field(:atTx, 3, type: :uint64)
  field(:sinceTx, 4, type: :uint64)
end

defmodule Immudb.Schema.VerifiableSQLGetRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:sqlGetRequest, 1, type: Immudb.Schema.SQLGetRequest)
  field(:proveSinceTx, 2, type: :uint64)
end

defmodule Immudb.Schema.SQLEntry do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:tx, 1, type: :uint64)
  field(:key, 2, type: :bytes)
  field(:value, 3, type: :bytes)
end

defmodule Immudb.Schema.VerifiableSQLEntry.ColIdsByIdEntry do
  @moduledoc false
  use Protobuf, map: true, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:key, 1, type: :uint64)
  field(:value, 2, type: :string)
end

defmodule Immudb.Schema.VerifiableSQLEntry.ColIdsByNameEntry do
  @moduledoc false
  use Protobuf, map: true, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:key, 1, type: :string)
  field(:value, 2, type: :uint64)
end

defmodule Immudb.Schema.VerifiableSQLEntry.ColTypesByIdEntry do
  @moduledoc false
  use Protobuf, map: true, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:key, 1, type: :uint64)
  field(:value, 2, type: :string)
end

defmodule Immudb.Schema.VerifiableSQLEntry do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:sqlEntry, 1, type: Immudb.Schema.SQLEntry)
  field(:verifiableTx, 2, type: Immudb.Schema.VerifiableTx)
  field(:inclusionProof, 3, type: Immudb.Schema.InclusionProof)
  field(:DatabaseId, 4, type: :uint64)
  field(:TableId, 5, type: :uint64)
  field(:PKName, 6, type: :string)

  field(:ColIdsById, 8,
    repeated: true,
    type: Immudb.Schema.VerifiableSQLEntry.ColIdsByIdEntry,
    map: true
  )

  field(:ColIdsByName, 9,
    repeated: true,
    type: Immudb.Schema.VerifiableSQLEntry.ColIdsByNameEntry,
    map: true
  )

  field(:ColTypesById, 10,
    repeated: true,
    type: Immudb.Schema.VerifiableSQLEntry.ColTypesByIdEntry,
    map: true
  )
end

defmodule Immudb.Schema.UseDatabaseReply do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:token, 1, type: :string)
end

defmodule Immudb.Schema.ChangePermissionRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:action, 1, type: Immudb.Schema.PermissionAction, enum: true)
  field(:username, 2, type: :string)
  field(:database, 3, type: :string)
  field(:permission, 4, type: :uint32)
end

defmodule Immudb.Schema.SetActiveUserRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:active, 1, type: :bool)
  field(:username, 2, type: :string)
end

defmodule Immudb.Schema.DatabaseListResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:databases, 1, repeated: true, type: Immudb.Schema.Database)
end

defmodule Immudb.Schema.Chunk do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:content, 1, type: :bytes)
end

defmodule Immudb.Schema.UseSnapshotRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:sinceTx, 1, type: :uint64)
  field(:asBeforeTx, 2, type: :uint64)
end

defmodule Immudb.Schema.SQLExecRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:sql, 1, type: :string)
  field(:params, 2, repeated: true, type: Immudb.Schema.NamedParam)
  field(:noWait, 3, type: :bool)
end

defmodule Immudb.Schema.SQLQueryRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:sql, 1, type: :string)
  field(:params, 2, repeated: true, type: Immudb.Schema.NamedParam)
  field(:reuseSnapshot, 3, type: :bool)
end

defmodule Immudb.Schema.NamedParam do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:name, 1, type: :string)
  field(:value, 2, type: Immudb.Schema.SQLValue)
end

defmodule Immudb.Schema.SQLExecResult do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:ctxs, 1, repeated: true, type: Immudb.Schema.TxMetadata)
  field(:dtxs, 2, repeated: true, type: Immudb.Schema.TxMetadata)
end

defmodule Immudb.Schema.SQLQueryResult do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:columns, 2, repeated: true, type: Immudb.Schema.Column)
  field(:rows, 1, repeated: true, type: Immudb.Schema.Row)
end

defmodule Immudb.Schema.Column do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:name, 1, type: :string)
  field(:type, 2, type: :string)
end

defmodule Immudb.Schema.Row do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field(:columns, 1, repeated: true, type: :string)
  field(:values, 2, repeated: true, type: Immudb.Schema.SQLValue)
end

defmodule Immudb.Schema.SQLValue do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  oneof(:value, 0)

  field(:null, 1, type: Google.Protobuf.NullValue, enum: true, oneof: 0)
  field(:n, 2, type: :uint64, oneof: 0)
  field(:s, 3, type: :string, oneof: 0)
  field(:b, 4, type: :bool, oneof: 0)
  field(:bs, 5, type: :bytes, oneof: 0)
end

defmodule Immudb.Schema.ImmuService.Service do
  @moduledoc false
  use GRPC.Service, name: "immudb.schema.ImmuService", protoc_gen_elixir_version: "0.10.0"

  rpc(:ListUsers, Google.Protobuf.Empty, Immudb.Schema.UserList)

  rpc(:CreateUser, Immudb.Schema.CreateUserRequest, Google.Protobuf.Empty)

  rpc(:ChangePassword, Immudb.Schema.ChangePasswordRequest, Google.Protobuf.Empty)

  rpc(:UpdateAuthConfig, Immudb.Schema.AuthConfig, Google.Protobuf.Empty)

  rpc(:UpdateMTLSConfig, Immudb.Schema.MTLSConfig, Google.Protobuf.Empty)

  rpc(:Login, Immudb.Schema.LoginRequest, Immudb.Schema.LoginResponse)

  rpc(:Logout, Google.Protobuf.Empty, Google.Protobuf.Empty)

  rpc(:Set, Immudb.Schema.SetRequest, Immudb.Schema.TxMetadata)

  rpc(:VerifiableSet, Immudb.Schema.VerifiableSetRequest, Immudb.Schema.VerifiableTx)

  rpc(:Get, Immudb.Schema.KeyRequest, Immudb.Schema.Entry)

  rpc(:VerifiableGet, Immudb.Schema.VerifiableGetRequest, Immudb.Schema.VerifiableEntry)

  rpc(:GetAll, Immudb.Schema.KeyListRequest, Immudb.Schema.Entries)

  rpc(:ExecAll, Immudb.Schema.ExecAllRequest, Immudb.Schema.TxMetadata)

  rpc(:Scan, Immudb.Schema.ScanRequest, Immudb.Schema.Entries)

  rpc(:Count, Immudb.Schema.KeyPrefix, Immudb.Schema.EntryCount)

  rpc(:CountAll, Google.Protobuf.Empty, Immudb.Schema.EntryCount)

  rpc(:TxById, Immudb.Schema.TxRequest, Immudb.Schema.Tx)

  rpc(:VerifiableTxById, Immudb.Schema.VerifiableTxRequest, Immudb.Schema.VerifiableTx)

  rpc(:TxScan, Immudb.Schema.TxScanRequest, Immudb.Schema.TxList)

  rpc(:History, Immudb.Schema.HistoryRequest, Immudb.Schema.Entries)

  rpc(:Health, Google.Protobuf.Empty, Immudb.Schema.HealthResponse)

  rpc(:CurrentState, Google.Protobuf.Empty, Immudb.Schema.ImmutableState)

  rpc(:SetReference, Immudb.Schema.ReferenceRequest, Immudb.Schema.TxMetadata)

  rpc(
    :VerifiableSetReference,
    Immudb.Schema.VerifiableReferenceRequest,
    Immudb.Schema.VerifiableTx
  )

  rpc(:ZAdd, Immudb.Schema.ZAddRequest, Immudb.Schema.TxMetadata)

  rpc(:VerifiableZAdd, Immudb.Schema.VerifiableZAddRequest, Immudb.Schema.VerifiableTx)

  rpc(:ZScan, Immudb.Schema.ZScanRequest, Immudb.Schema.ZEntries)

  rpc(:CreateDatabase, Immudb.Schema.Database, Google.Protobuf.Empty)

  rpc(:DatabaseList, Google.Protobuf.Empty, Immudb.Schema.DatabaseListResponse)

  rpc(:UseDatabase, Immudb.Schema.Database, Immudb.Schema.UseDatabaseReply)

  rpc(:CompactIndex, Google.Protobuf.Empty, Google.Protobuf.Empty)

  rpc(:ChangePermission, Immudb.Schema.ChangePermissionRequest, Google.Protobuf.Empty)

  rpc(:SetActiveUser, Immudb.Schema.SetActiveUserRequest, Google.Protobuf.Empty)

  rpc(:streamGet, Immudb.Schema.KeyRequest, stream(Immudb.Schema.Chunk))

  rpc(:streamSet, stream(Immudb.Schema.Chunk), Immudb.Schema.TxMetadata)

  rpc(:streamVerifiableGet, Immudb.Schema.VerifiableGetRequest, stream(Immudb.Schema.Chunk))

  rpc(:streamVerifiableSet, stream(Immudb.Schema.Chunk), Immudb.Schema.VerifiableTx)

  rpc(:streamScan, Immudb.Schema.ScanRequest, stream(Immudb.Schema.Chunk))

  rpc(:streamZScan, Immudb.Schema.ZScanRequest, stream(Immudb.Schema.Chunk))

  rpc(:streamHistory, Immudb.Schema.HistoryRequest, stream(Immudb.Schema.Chunk))

  rpc(:streamExecAll, stream(Immudb.Schema.Chunk), Immudb.Schema.TxMetadata)

  rpc(:UseSnapshot, Immudb.Schema.UseSnapshotRequest, Google.Protobuf.Empty)

  rpc(:SQLExec, Immudb.Schema.SQLExecRequest, Immudb.Schema.SQLExecResult)

  rpc(:SQLQuery, Immudb.Schema.SQLQueryRequest, Immudb.Schema.SQLQueryResult)

  rpc(:ListTables, Google.Protobuf.Empty, Immudb.Schema.SQLQueryResult)

  rpc(:DescribeTable, Immudb.Schema.Table, Immudb.Schema.SQLQueryResult)

  rpc(:VerifiableSQLGet, Immudb.Schema.VerifiableSQLGetRequest, Immudb.Schema.VerifiableSQLEntry)
end

defmodule Immudb.Schema.ImmuService.Stub do
  @moduledoc false
  use GRPC.Stub, service: Immudb.Schema.ImmuService.Service
end
