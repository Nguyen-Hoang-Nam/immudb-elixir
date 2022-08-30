defmodule Immudb.Schemas.VerifiableTx do
  @type t :: %__MODULE__{
          dual_proof: Immudb.Schemas.DualProof.t(),
          signature: binary(),
          tx: Immudb.Schemas.Tx.t()
        }
  defstruct dual_proof: nil,
            signature: nil,
            tx: nil

  def convert(%{
        dualProof: dual_proof,
        signature: signature,
        tx: tx
      }) do
    %Immudb.Schemas.VerifiableTx{
      dual_proof: dual_proof |> Immudb.Schemas.DualProof.convert(),
      signature: signature,
      tx: tx |> Immudb.Schemas.Tx.convert()
    }
  end
end
