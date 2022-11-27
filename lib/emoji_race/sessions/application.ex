defmodule EmojiRace.Sessions.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      %{id: Registry.RaceRegistry, start: {Registry.RaceRegistry, :start_link, [keys: :unique, name: Registry.RaceRegistry]}},
      {DynamicSupervisor, name: EmojiRace.Race.Supervisor, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: EmojiRace.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
