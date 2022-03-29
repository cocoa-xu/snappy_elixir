defmodule SnappyTest do
  use ExUnit.Case
  doctest Snappy

  test "compress" do
    assert {:ok, <<20, 0, 97, 74, 1, 0>>} = Snappy.compress("aaaaaaaaaaaaaaaaaaaa")
  end

  test "uncompress" do
    assert {:ok, "aaaaaaaaaaaaaaaaaaaa"} = Snappy.uncompress(<<20, 0, 97, 74, 1, 0>>)
    assert {:error, "snappy::GetUncompressedLength failed"} = Snappy.uncompress(<<>>)
    assert {:error, "snappy::RawUncompress failed"} = Snappy.uncompress(<<1>>)
  end

  test "max_compressed_length" do
    assert {:ok, 55} = Snappy.max_compressed_length("aaaaaaaaaaaaaaaaaaaa")
  end

  test "uncompressed_length" do
    assert {:ok, 20} = Snappy.uncompressed_length(<<20, 0, 97, 74, 1, 0>>)
    assert {:error, "snappy::GetUncompressedLength failed"} = Snappy.uncompressed_length(<<>>)
  end

  test "valid_compressed_buffer?" do
    {:ok, compressed} = Snappy.compress("aaaaaaaaaaaaaaaaaaaa")
    assert {:ok, true} = Snappy.valid_compressed_buffer?(compressed)
    assert {:ok, false} = Snappy.valid_compressed_buffer?(<<>>)
  end
end
