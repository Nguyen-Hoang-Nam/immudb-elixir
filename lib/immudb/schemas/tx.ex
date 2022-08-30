defmodule Immudb.Schemas.Tx do
  @type t :: %__MODULE__{
          entries: [Immudb.Schemas.TxEntry.t()],
          metadata: Immudb.Schemas.TxMetaData.t()
        }
  defstruct entries: [],
            metadata: nil

  def convert(%{
        entries: entries,
        metadata: metadata
      }) do
    %Immudb.Schemas.Tx{
      entries: entries |> Enum.map(fn entry -> entry |> Immudb.Schemas.TxEntry.convert() end),
      metadata: metadata
    }
  end
end
