defmodule Immudb.Schemas.TxMetaData do
  @type t :: %__MODULE__{
          bl_root: binary(),
          bl_tx_id: integer(),
          e_h: binary(),
          id: integer(),
          nentries: integer(),
          prev_alh: binary(),
          ts: integer()
        }
  defstruct bl_root: nil, bl_tx_id: nil, e_h: nil, id: nil, nentries: nil, prev_alh: nil, ts: nil

  def convert(%{
        blRoot: bl_root,
        blTxId: bl_tx_id,
        eH: e_h,
        id: id,
        nentries: nentries,
        prevAlh: prev_alh,
        ts: ts
      }) do
    %Immudb.Schemas.TxMetaData{
      bl_root: bl_root,
      bl_tx_id: bl_tx_id,
      e_h: e_h,
      id: id,
      nentries: nentries,
      prev_alh: prev_alh,
      ts: ts
    }
  end
end
