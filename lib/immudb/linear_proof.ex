defmodule Immudb.LinearProof do
  @type t :: %__MODULE__{
          target_tx_id: integer(),
          source_tx_id: integer(),
          terms: [binary()]
        }
  defstruct target_tx_id: nil,
            source_tx_id: nil,
            terms: []

  def convert(%{TargetTxId: target_tx_id, sourceTxId: source_tx_id, terms: terms}) do
    %Immudb.LinearProof{
      target_tx_id: target_tx_id,
      source_tx_id: source_tx_id,
      terms: terms
    }
  end
end
