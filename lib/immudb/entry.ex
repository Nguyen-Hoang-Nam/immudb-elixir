defmodule Immudb.Entry do
  @type t :: %__MODULE__{
          key: binary(),
          referenced_by: binary(),
          tx: integer(),
          value: binary()
        }
  defstruct key: nil, referenced_by: nil, tx: nil, value: nil

  def convert(%{key: key, referencedBy: referenced_by, tx: tx, value: value}) do
    %Immudb.Entry{
      key: key,
      referenced_by: referenced_by,
      tx: tx,
      value: value
    }
  end
end
