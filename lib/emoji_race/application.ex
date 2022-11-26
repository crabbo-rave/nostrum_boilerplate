defmodule EmojiRace.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {EmojiRace.Consumer.Supervisor, []},
      %{
        id: EmojiRace.Edit,
        start: {EmojiRace.Edit, :start_link, []}
      },
      {DynamicSupervisor, name: EmojiRace.Race.Supervisor, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: EmojiRace.Supervisor]
    Supervisor.start_link(children, opts)

    Registry.start_link(keys: :unique, name: Registry.RaceRegistry) # TODO: Supervise with Dynamic Supervisor, and/or supervise in children
  end
end
