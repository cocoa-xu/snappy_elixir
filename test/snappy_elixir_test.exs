defmodule SnappyElixirTest do
  use ExUnit.Case
  doctest SnappyElixir

  test "greets the world" do
    assert SnappyElixir.hello() == :world
  end
end
