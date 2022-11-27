defmodule EmojiRace.Sessions do
  @moduledoc """
  Game sessions
  """
  def start_race(id, len, wait) do
    spec = %{id: EmojiRace.Sessions.Race, start: {EmojiRace.Sessions.Race, :start_link, [id, len, wait]}}
    DynamicSupervisor.start_child(EmojiRace.Race.Supervisor, spec)
  end

  def session_name(id) do
    {:via, Registry, {Registry.RaceRegistry, id}}
  end
end
