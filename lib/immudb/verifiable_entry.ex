defmodule Immudb.VerifiableEntry do
  @type t :: %__MODULE__{
          entry: Immudb.Entry.t(),
          inclusion_proof: Immudb.InclusionProof.t(),
          verifiable_tx: Immudb.VerifiableTx.t()
        }
  defstruct entry: nil,
            inclusion_proof: nil,
            verifiable_tx: nil

  def convert(%{
        entry: entry,
        inclusionProof: inclusion_proof,
        verifiableTx: verifiable_tx
      }) do
    %Immudb.VerifiableEntry{
      entry: entry |> Immudb.Entry.convert(),
      inclusion_proof: inclusion_proof |> Immudb.InclusionProof.convert(),
      verifiable_tx: verifiable_tx |> Immudb.VerifiableTx.convert()
    }
  end
end
