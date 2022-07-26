# Immudb Elixir

The Elixir implementation of Immudb client.

## Installation

```elixir
def deps do
  [
    {:immudb_elixir, git: "https://github.com/Nguyen-Hoang-Nam/immudb-elixir.git"}
  ]
end
```

## Usage

### Connect to Immudb

You can connect to Immudb in 2 ways

```elixir
{:ok, immudb} = Immudb.new(
    host: host,
    port: port,
    username: username,
    password: password,
    database: database
)
```

```elixir
{:ok, immudb} = Immudb.new(
    url: "immudb://user:pass@host:port/dbname"
)
```

### Key value

Set key and value

```elixir
immudb
|> Immudb.set("Hello", "World")
```

Get value from key

```elixir
immudb
|> Immudb.get("Hello")
```

Set with verification

```elixir
immudb
|> Immudb.verified_set("Hello", "World")
```

Get with verification

```elixir
immudb
|> Immudb.verified_get("Hello")
```

### SQL

Execute sql (create, insert)

```elixir
immudb
|> Immudb.sql_exec("CREATE TABLE hello (id INTEGER, name VARCHAR, PRIMARY KEY id)")
immudb
|> Immudb.sql_exec("INSERT INTO hello (id, name) VALUES (@id, @name)", %{id: 1, name: "World"})
```

Query table

```elixir
immudb
|> Immudb.sql_query("SELECT * FROM hello WHERE id == @id", %{id: 1})
```
