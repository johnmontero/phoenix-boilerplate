defmodule UmbrellaProject.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:credo, "~> 1.4.0", only: [:dev, :test], runtime: false},
      {:distillery, "~> 2.1"},
      {:config_tuples, "~> 0.4.2"},
      {:telemetry, "~> 0.4.1"}
    ]
  end
end
