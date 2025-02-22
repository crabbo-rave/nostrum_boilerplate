defmodule EmojiRace.MixProject do
  use Mix.Project

  def project do
    [
      app: :emoji_race,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {EmojiRace.Application, []},
      mod: {EmojiRace.Sessions.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dotenv_parser, "~> 2.0"},
      {:nostrum, "~> 0.6"}
    ]
  end
end
