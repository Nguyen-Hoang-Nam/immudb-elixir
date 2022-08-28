defmodule Immudb.Tx do
  @type t :: %__MODULE__{
          entries: [Immudb.TxEntry.t()],
          metadata: Immudb.TxMetaData.t()
        }
  defstruct entries: [],
            metadata: nil

  def convert(%{
        entries: entries,
        metadata: metadata
      }) do
    %Immudb.Tx{
      entries: entries |> Enum.map(fn entry -> entry |> Immudb.TxEntry.convert() end),
      metadata: metadata
    }
  end
end
