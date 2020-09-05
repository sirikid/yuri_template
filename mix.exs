defmodule YuriTemplate.MixProject do
  use Mix.Project

  def project do
    [
      app: :yuri_template,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        flags: [
          :error_handling,
          :no_opaque,
          # :underspecs,
          # :overspecs,
          :race_conditions
        ]
      ],
      preferred_cli_env: [
        dialyzer: :dev
      ]
    ]
  end

  def application, do: []

  defp deps do
    [
      {:nimble_parsec, "~> 0.5.3"},
      {:dialyxir, "~> 0.5.1", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22.2", only: :dev, runtime: false}
    ]
  end
end
