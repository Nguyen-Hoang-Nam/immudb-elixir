defmodule Immudb.Schemas.VerifiableEntry do
  @type t :: %__MODULE__{
          entry: Immudb.Schemas.Entry.t(),
          inclusion_proof: Immudb.Schemas.InclusionProof.t(),
          verifiable_tx: Immudb.Schemas.VerifiableTx.t()
        }
  defstruct entry: nil,
            inclusion_proof: nil,
            verifiable_tx: nil

  def convert(%{
        entry: entry,
        inclusionProof: inclusion_proof,
        verifiableTx: verifiable_tx
      }) do
    %Immudb.Schemas.VerifiableEntry{
      entry: entry |> Immudb.Schemas.Entry.convert(),
      inclusion_proof: inclusion_proof |> Immudb.Schemas.InclusionProof.convert(),
      verifiable_tx: verifiable_tx |> Immudb.Schemas.VerifiableTx.convert()
    }
  end
end
