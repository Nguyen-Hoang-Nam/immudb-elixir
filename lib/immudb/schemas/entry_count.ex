defmodule Immudb.Schemas.EntryCount do
  @type t :: %__MODULE__{
          count: integer()
        }
  defstruct count: nil
end
