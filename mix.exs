defmodule YuriTemplate.MixProject do
  use Mix.Project

  def project do
    [
      app: :yuri_template,
      version: "1.0.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        flags: [
          :error_handling,
          :no_opaque,
          :underspecs,
          :overspecs,
          :race_conditions
        ]
      ],
      preferred_cli_env: [
        dialyzer: :dev
      ],
      # Hex
      description: "An RFC6570 implementation",
      package: package(),
      # Docs
      source_url: "https://github.com/sirikid/yuri_template"
    ]
  end

  def application, do: []

  defp deps do
    [
      {:nimble_parsec, "~> 1.0"},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"Github" => "https://github.com/sirikid/yuri_template"}
    ]
  end
end
