defmodule Immudb.Util do
  def metadata(token) do
    %{authorization: "Bearer #{token}", content_type: "application/grpc"}
  end
end
