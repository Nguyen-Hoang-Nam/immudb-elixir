defmodule Immudb.ClientTest do
  use ExUnit.Case

  test "New connection" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token}} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()
  end

  test "New connection 2" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token}} =
             Immudb.new(url: "immudb://immudb:immudb@localhost:3322/defaultdb")

    assert token |> Kernel.is_bitstring()
  end

  test "New connection with wrong host" do
    assert {:error, :timeout} =
             Immudb.new(
               host: "host",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )
  end

  test "New connection with wrong port" do
    assert {:error, :timeout} =
             Immudb.new(
               host: "localhost",
               port: 3321,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )
  end

  test "New connection with wrong username" do
    assert {:error, "invalid user name or password"} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "wrong username",
               password: "immudb",
               database: "defaultdb"
             )
  end

  test "New connection with wrong password" do
    assert {:error, "invalid user name or password"} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "wrong password",
               database: "defaultdb"
             )
  end

  test "New connection with wrong database" do
    assert {:error, "'wrongdb' does not exist"} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "wrongdb"
             )
  end

  test "Login" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    assert {:ok, token} =
             socket
             |> Immudb.login("immudb", "immudb")

    assert token |> Kernel.is_bitstring()
  end

  test "Login with wrong username" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    assert {:error, "invalid user name or password"} =
             socket
             |> Immudb.login("wrong username", "immudb")

    assert token |> Kernel.is_bitstring()
  end

  test "Login with wrong password" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    assert {:error, "invalid user name or password"} =
             socket
             |> Immudb.login("immudb", "wrong password")

    assert token |> Kernel.is_bitstring()
  end

  test "Logout" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    assert {:ok, nil} =
             socket
             |> Immudb.logout()
  end

  test "List user" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token}} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()
  end

  test "Create user" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    assert {:ok, nil} =
             socket
             |> Immudb.create_user(
               user: "test_#{:os.system_time(:millisecond)}",
               password: "Abcdef12!",
               database: "defaultdb",
               permission: :read
             )
  end

  test "Create user with invalid password" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    assert {:error,
            "password must have between 8 and 32 letters, digits and special characters of which at least 1 uppercase letter, 1 digit and 1 special character"} =
             socket
             |> Immudb.create_user(
               user: "test_#{:os.system_time(:millisecond)}",
               password: "bcdef12!",
               database: "defaultdb",
               permission: :read
             )
  end

  test "Change password" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    user = "test_#{:os.system_time(:millisecond)}"

    assert {:ok, nil} =
             socket
             |> Immudb.create_user(
               user: user,
               password: "Abcdef12!",
               database: "defaultdb",
               permission: :read
             )

    assert {:ok, nil} =
             socket
             |> Immudb.change_password(
               user: user,
               old_password: "Abcdef12!",
               new_password: "Abcdef13!"
             )
  end

  test "Change password with wrong password" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    user = "test_#{:os.system_time(:millisecond)}"

    assert {:ok, nil} =
             socket
             |> Immudb.create_user(
               user: user,
               password: "Abcdef12!",
               database: "defaultdb",
               permission: :read
             )

    assert {:ok, nil} =
             socket
             |> Immudb.change_password(
               user: user,
               old_password: "wrong password",
               new_password: "Abcdef13!"
             )
  end

  test "Change password with invalid password" do
    assert {:ok, %Immudb.Socket{channel: %GRPC.Channel{}, token: token} = socket} =
             Immudb.new(
               host: "localhost",
               port: 3322,
               username: "immudb",
               password: "immudb",
               database: "defaultdb"
             )

    assert token |> Kernel.is_bitstring()

    user = "test_#{:os.system_time(:millisecond)}"

    assert {:ok, nil} =
             socket
             |> Immudb.create_user(
               user: user,
               password: "Abcdef12!",
               database: "defaultdb",
               permission: :read
             )

    assert {:ok, nil} =
             socket
             |> Immudb.change_password(
               user: user,
               old_password: "Abcdef12!",
               new_password: "bcdef13!"
             )
  end
end
