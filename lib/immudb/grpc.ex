defmodule Immudb.Grpc do
  def schema do
    quote do
      alias Immudb.Schema
      alias Immudb.Schema.ImmuService.Stub
      alias Google.Protobuf
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
