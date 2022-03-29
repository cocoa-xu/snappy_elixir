defmodule Snappy.Nif do
  @moduledoc false

  @on_load :load_nif
  def load_nif do
    nif_file = '#{:code.priv_dir(:snappy)}/nif'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> IO.puts("Failed to load nif: #{inspect(reason)}")
    end
  end

  def compress(_data), do: :erlang.nif_error(:not_loaded)
  def uncompress(_data), do: :erlang.nif_error(:not_loaded)
  def max_compressed_length(_data), do: :erlang.nif_error(:not_loaded)
  def uncompressed_length(_data), do: :erlang.nif_error(:not_loaded)
  def is_valid_compressed_buffer(_data, _size), do: :erlang.nif_error(:not_loaded)
end
