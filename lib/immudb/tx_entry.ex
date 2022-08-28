defmodule Immudb.TxEntry do
  @type t :: %__MODULE__{
          h_value: binary(),
          key: binary(),
          v_len: integer(),
          v_off: integer()
        }
  defstruct h_value: nil,
            key: nil,
            v_len: nil,
            v_off: nil

  def convert(%{hValue: h_value, key: key, vLen: v_len, vOff: v_off}) do
    %Immudb.TxEntry{
      h_value: h_value,
      key: key,
      v_len: v_len,
      v_off: v_off
    }
  end
end
