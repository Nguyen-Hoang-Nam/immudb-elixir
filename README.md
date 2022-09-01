# Immudb Elixir

The implementation of Immudb client in Elixir.

## Installation

```elixir
def deps do
  [
    {:immudb_elixir, "~> 0.2.0"}
  ]
end
```

## Usage

### Connecting to Immudb

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

### TODO

- [ ] update_auth_config
- [ ] update_mtls_config
- [ ] exec_all
- [ ] z_add
- [ ] verifiable_z_add
- [ ] z_scan
- [ ] stream
- [ ] Test sql command

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[Apache License 2.0](https://choosealicense.com/licenses/apache-2.0/)
