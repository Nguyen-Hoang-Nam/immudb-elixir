defmodule Immudb.Socket do
  @type t :: %__MODULE__{channel: GRPC.Channel.t(), token: String.t()}
  defstruct channel: nil, token: nil
end
