defmodule SnappyElixir.MixProject do
  use Mix.Project

  @app :snappy
  @version "0.1.0-dev"
  @default_package_version "1.1.9"
  @source_url "https://github.com/cocoa-xu/snappy_elixir/tree/main"

  defp download_if_needed(package_ver, prefer_precompiled) do
    if prefer_precompiled == "false" and System.get_env("SNAPPY_USE_GIT_HEAD", "false") == "false" do
      #  in simple words
      #  1. download "https://github.com/google/snappy/archive/$(SNAPPY_VER).zip" to "3rd_party/cache/snappy-$(SNAPPY_VER).zip"
      #  2. unzip -o "3rd_party/cache/snappy-$(SNAPPY_VER).zip" -d "SNAPPY_ROOT_DIR"
      #   3rd_party
      #   ├── cache
      #   │   └── snappy_$(SNAPPY_VER).zip
      #   └── snappy
      #       └── snappy-$(SNAPPY_VER)
      package_name = "snappy"
      source_zip_url = "https://github.com/google/snappy/archive/#{package_ver}.zip"
      cache_dir = Path.join([__DIR__, "3rd_party", "cache"])
      File.mkdir_p!(cache_dir)
      cache_location = Path.join([__DIR__, "3rd_party", "cache", "#{package_name}-#{package_ver}.zip"])
      source_root_dir = Path.join([__DIR__, "3rd_party", package_name])
      File.mkdir_p!(source_root_dir)
      source_dir = Path.join([__DIR__, "3rd_party", package_name, "#{package_name}-#{package_ver}"])
      if !File.dir?(source_dir) do
        :ssl.start()
        :inets.start()
        download!(source_zip_url, cache_location)

        :zip.unzip(String.to_charlist(cache_location), [
          {:cwd, String.to_charlist(source_root_dir)}
        ])
      end
    end
  end

  def project do
    package_ver = System.get_env("SNAPPY_VER", @default_package_version)
    download_if_needed(package_ver, System.get_env("SNAPPY_PREFER_PRECOMPILED", "false"))
    ninja = System.find_executable("ninja")

    [
      app: @app,
      name: "Snappy",
      version: @version,
      deps: deps(),
      docs: docs(),
      compilers: [:elixir_make] ++ Mix.compilers(),
      elixirc_paths: elixirc_paths(Mix.env()),
      source_url: "https://github.com/cocox-xu/snappy_elixir",
      description: description(),
      elixir: "~> 1.11-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      make_executable: make_executable(),
      make_makefile: make_makefile(),
      make_env: %{
        "HAVE_NINJA" => "#{ninja != nil}",
        "SNAPPY_VER" => package_ver,
        "MAKE_BUILD_FLAGS" =>
          System.get_env("MAKE_BUILD_FLAGS", "-j#{System.schedulers_online()}"),
        "SNAPPY_PREFER_PRECOMPILED" => System.get_env("SNAPPY_PREFER_PRECOMPILED", "false"),
        "SNAPPY_PRECOMPILED_VERSION" => System.get_env("SNAPPY_PRECOMPILED_VERSION", @version)
      }
    ]
  end

  def make_executable() do
    case :os.type() do
      {:win32, _} -> "nmake"
      _ -> "make"
    end
  end

  defp elixirc_paths(_), do: ~w(lib)

  def make_makefile() do
    case :os.type() do
      {:win32, _} -> "Makefile.win"
      _ -> "Makefile"
    end
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "Snappy-Elixir bindings."
  end

  defp package() do
    [
      name: "snappy",
      files:
        ~w(lib c_src py_src 3rd_party priv .formatter.exs mix.exs README* LICENSE*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/cocoa-xu/snappy_elixir"}
    ]
  end

  defp docs do
    [
      main: "Snappy",
      source_ref: "v#{@version}",
      source_url: @source_url,
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.6"},
      {:dll_loader_helper, "~> 0.1.0"},
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
    ]
  end

  defp download!(url, save_as, overwrite \\ false)

  defp download!(url, save_as, false) do
    unless File.exists?(save_as) do
      download!(url, save_as, true)
    end

    :ok
  end

  defp download!(url, save_as, true) do
    http_opts = []
    opts = [body_format: :binary]
    arg = {url, []}

    body =
      case :httpc.request(:get, arg, http_opts, opts) do
        {:ok, {{_, 200, _}, _, body}} ->
          body

        {:error, reason} ->
          raise inspect(reason)
      end

    File.write!(save_as, body)
  end
end
