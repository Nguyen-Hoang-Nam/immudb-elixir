defmodule Immudb.Permission do
  @type t :: %__MODULE__{database: String.t(), permission: integer()}
  defstruct database: nil, permission: nil

  @spec to_int(atom()) :: integer()
  def to_int(:sys_admin) do
    255
  end

  def to_int(:admin) do
    254
  end

  def to_int(:none) do
    0
  end

  def to_int(:read) do
    1
  end

  def to_int(:read_write) do
    2
  end

  @spec to_atom(integer()) :: atom()
  def to_atom(255) do
    :sys_admin
  end

  def to_atom(254) do
    :admin
  end

  def to_atom(0) do
    :none
  end

  def to_atom(1) do
    :read
  end

  def to_atom(2) do
    :read_write
  end
end
