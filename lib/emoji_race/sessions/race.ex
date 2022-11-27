defmodule EmojiRace.Sessions.Race do
  alias EmojiRace.Sessions.Racer

  @emojies ["🤣", "😁", "🙈", "🔥", "😎", "😱", "🤡", "🦀", "🍾", "🙃"]

  def get_emoji(racers) do
    emojies = for emoji <- @emojies, do: %{name: emoji}
    racer_emojies = for %{emoji: e} <- racers, do: e
    Enum.random(Enum.filter(emojies, &(&1.name not in racer_emojies)))
  end

  def join(user, racers, start, wait) do
    cond do
      System.system_time() - start > wait -> {:error, :slow_poke}
      true -> {:ok, [user | racers]}
    end
  end

  def move(racers) do
    racers
    |> Enum.map(fn racer -> %Racer{racer | done: racer.done + rem(:erlang.unique_integer([:positive]), 10)} end)
  end
end
