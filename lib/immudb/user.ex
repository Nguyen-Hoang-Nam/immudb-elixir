defmodule Immudb.User do
  @type t :: %__MODULE__{
          active: String.t(),
          create_date: String.t(),
          created_by: String.t(),
          permissions: [Immudb.Permission.t()],
          user: String.t()
        }
  defstruct active: nil, create_date: nil, created_by: nil, permissions: [], user: nil

  def convert(users) do
    users
    |> Enum.map(fn
      %{
        active: active,
        createdat: create_date,
        createdby: created_by,
        permissions: permissions,
        user: user
      } ->
        %Immudb.User{
          active: active,
          create_date: create_date,
          created_by: created_by,
          permissions:
            permissions
            |> Enum.map(fn %{database: database, permission: permission} ->
              %Immudb.Permission{
                database: database,
                permission: permission |> Immudb.Permission.to_atom()
              }
            end),
          user: user
        }
    end)
  end
end
