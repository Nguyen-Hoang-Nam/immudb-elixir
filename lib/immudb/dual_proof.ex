defmodule Immudb.DualProof do
  @type t :: %__MODULE__{
          consistency_proof: [binary()],
          inclusion_proof: [binary()],
          last_inclusion_proof: [binary()],
          linear_proof: Immudb.LinearProof.t(),
          source_tx_metadata: Immudb.TxMetaData.t(),
          target_bl_tx_alh: binary(),
          target_tx_metadata: Immudb.TxMetaData.t()
        }
  defstruct consistency_proof: [],
            inclusion_proof: [],
            last_inclusion_proof: [],
            linear_proof: nil,
            source_tx_metadata: nil,
            target_bl_tx_alh: nil,
            target_tx_metadata: nil

  def convert(%{
        consistencyProof: consitency_proof,
        inclusionProof: inclusion_proof,
        lastInclusionProof: last_inclusion_proof,
        linearProof: linear_proof,
        sourceTxMetadata: source_tx_metadata,
        targetBlTxAlh: target_bl_tx_alh,
        targetTxMetadata: target_tx_metadata
      }) do
    %Immudb.DualProof{
      consistency_proof: consitency_proof,
      inclusion_proof: inclusion_proof,
      last_inclusion_proof: last_inclusion_proof,
      linear_proof: linear_proof |> Immudb.LinearProof.convert(),
      source_tx_metadata: source_tx_metadata |> Immudb.TxMetaData.convert(),
      target_bl_tx_alh: target_bl_tx_alh,
      target_tx_metadata: target_tx_metadata |> Immudb.TxMetaData.convert()
    }
  end

  def convert(_) do
    :not_found
  end
end
