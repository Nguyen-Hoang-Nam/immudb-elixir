defmodule Immudb.Util do
  def metadata(socket) do
    %{authorization: "Bearer #{socket.token}", content_type: "application/grpc"}
  end
end
