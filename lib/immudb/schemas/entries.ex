defmodule Immudb.Schemas.Entries do
  @type t :: %__MODULE__{
          entries: [Immudb.Schemas.Entry.t()]
        }
  defstruct entries: []

  def convert(%{entries: entries}) do
    %Immudb.Schemas.Entries{
      entries: entries |> Enum.map(fn v -> v |> Immudb.Schemas.Entry.convert() end)
    }
  end
end
