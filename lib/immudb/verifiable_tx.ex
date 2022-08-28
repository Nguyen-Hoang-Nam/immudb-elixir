defmodule Immudb.VerifiableTx do
  @type t :: %__MODULE__{
          dual_proof: Immudb.DualProof.t(),
          signature: binary(),
          tx: Immudb.Tx.t()
        }
  defstruct dual_proof: nil,
            signature: nil,
            tx: nil

  def convert(%{
        dualProof: dual_proof,
        signature: signature,
        tx: tx
      }) do
    %Immudb.VerifiableTx{
      dual_proof: dual_proof,
      signature: signature,
      tx: tx
    }
  end
end
