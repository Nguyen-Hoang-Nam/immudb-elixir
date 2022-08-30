defmodule Immudb.Schemas.InclusionProof do
  @type t :: %__MODULE__{
          leaf: integer(),
          terms: [binary()],
          width: integer()
        }
  defstruct leaf: nil,
            terms: [],
            width: nil

  def convert(%{
        leaf: leaf,
        terms: terms,
        width: width
      }) do
    %Immudb.Schemas.InclusionProof{
      leaf: leaf,
      terms: terms,
      width: width
    }
  end
end
