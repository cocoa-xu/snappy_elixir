defmodule Snappy do
  @moduledoc """
  An Elixir binding for snappy, a fast compressor/decompressor.
  """

  @doc """
  Compress

  ## Examples

      iex> {:ok, _compressed} = Snappy.compress("aaaaaaaaaaaaaaaaaaaa")
      {:ok, <<20, 0, 97, 74, 1, 0>>}

  """
  @spec compress(binary()) :: {:ok, binary()} | {:error, String.t()}
  def compress(data) when is_binary(data) do
    Snappy.Nif.compress(data)
  end

  @doc """
  Uncompress

  ## Examples

      iex> {:ok, compressed} = Snappy.compress("aaaaaaaaaaaaaaaaaaaa")
      {:ok, <<20, 0, 97, 74, 1, 0>>}
      iex> {:ok, _uncompressed} = Snappy.uncompress(compressed)
      {:ok, "aaaaaaaaaaaaaaaaaaaa"}

  """
  @spec uncompress(binary()) :: {:ok, binary()} | {:error, String.t()}
  def uncompress(data) when is_binary(data) do
    Snappy.Nif.uncompress(data)
  end

  @doc """
  Returns the maximal size of the compressed representation of
  input data that is "source_bytes" bytes in length;

  ## Examples

      iex> {:ok, _max_size} = Snappy.max_compressed_length("aaaaaaaaaaaaaaaaaaaa")
      {:ok, 55}

  """
  @spec max_compressed_length(binary()) :: {:ok, non_neg_integer()} | {:error, String.t()}
  def max_compressed_length(data) when is_binary(data) do
    Snappy.Nif.max_compressed_length(data)
  end

  @doc """
  Returns true and stores the length of the uncompressed data

  This operation takes O(1) time in C.

  ## Examples

      iex> {:ok, compressed} = Snappy.compress("aaaaaaaaaaaaaaaaaaaa")
      {:ok, <<20, 0, 97, 74, 1, 0>>}
      iex> {:ok, _uncompressed_length} = Snappy.uncompressed_length(compressed)
      {:ok, 20}

  """
  @spec uncompressed_length(binary()) :: {:ok, non_neg_integer()} | {:error, String.t()}
  def uncompressed_length(compressed) when is_binary(compressed) do
    Snappy.Nif.uncompressed_length(compressed)
  end

  @doc """
  Returns true iff the contents of "compressed" can be uncompressed
  successfully.  Does not return the uncompressed data.  Takes
  time proportional to compressed_length, but is usually at least
  a factor of four faster than actual decompression.

  ## Examples

      iex> {:ok, compressed} = Snappy.compress("aaaaaaaaaaaaaaaaaaaa")
      {:ok, <<20, 0, 97, 74, 1, 0>>}
      iex> {:ok, _valid} = Snappy.valid_compressed_buffer?(compressed)
      {:ok, true}

  """
  @spec valid_compressed_buffer?(binary()) :: true | false
  def valid_compressed_buffer?(compressed) when is_binary(compressed) do
    Snappy.Nif.is_valid_compressed_buffer(compressed, byte_size(compressed))
  end

  @spec valid_compressed_buffer?(binary(), pos_integer()) :: true | false
  def valid_compressed_buffer?(compressed, size) when is_binary(compressed) and size > 0 do
    Snappy.Nif.is_valid_compressed_buffer(compressed, size)
  end
end
