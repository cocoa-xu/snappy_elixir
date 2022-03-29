# SnappyElixir

A simple snappy-elixir binding.

## Usage
```elixir
iex> data = "aaaaaaaaaaaaaaaaaaaa"
iex> {:ok, compressed} = Snappy.compress(data)
{:ok, <<20, 0, 97, 74, 1, 0>>}
iex> true = Snappy.valid_compressed_buffer?(compressed)
iex> {:ok, uncompressed_length} = Snappy.uncompressed_length(compressed)
{:ok, 20}
iex> {:ok, uncompressed} = Snappy.uncompress(compressed)
{:ok, "aaaaaaaaaaaaaaaaaaaa"}
iex> {:ok, max_size} = Snappy.max_compressed_length(data)
{:ok, 55}
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `snappy_elixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:snappy_elixir, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/snappy_elixir>.

