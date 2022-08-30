defmodule Immudb.Schemas.TxList do
  @type t :: %__MODULE__{
          txs: [Immudb.Schemas.Tx.t()]
        }
  defstruct txs: []
end
