defmodule EmojiRace.Sessions.RaceServer do
  use GenServer

  alias EmojiRace.Sessions.Racer
  alias EmojiRace.Sessions
  alias EmojiRace.Sessions.Race
  alias EmojiRace.Commands.Join # move somewhere else

  @emojies ["🤣", "😁", "🙈", "🔥", "😎", "😱", "🤡", "🦀", "🍾", "🙃"] # FUTURE: get random emoji from server's emoji list

  def get_emoji(racers) do
    emojies = for emoji <- @emojies, do: %{name: emoji}
    racer_emojies = for %{emoji: e} <- racers, do: e
    Enum.random(Enum.filter(emojies, &(&1.name not in racer_emojies)))
  end

  @impl true
  def init({wait}) do
    now = System.system_time(:second)
    {:ok, %{start: now, wait: wait, racers: []}}
  end

  @impl true
  def handle_cast({:join, user_id}, %{racers: racers, start: start, wait: wait} = state) do
    user = %Racer{user: user_id, emoji: Race.get_emoji(racers)}
    case Race.join(user, racers, start, wait) do
      {:error, err} -> throw err
      {:ok, new_racers} -> {:noreply, %{state | racers: new_racers}}
    end
  end

  @impl true
  # timer = Process.send_after(self(), {:move, id}, 1000)

  # if Enum.count(state.racers) in [0,1] do
  #   throw :too_little_racers
  # else
  #   {:noreply, %{state | timer: timer}}
  # end

  def handle_info({:move, id}, state) do
    new_distances = Race.move(state.racers)

    if Enum.find(new_distances, fn racer -> racer.done == 100 end) != nil do
      {:noreply, %{state | racers: new_distances}}
    else
      timer = Process.send_after(self(), {:move, id}, 1000)

      {:noreply, %{state | racers: new_distances, timer: timer}}
    end
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  # API
  def start_link(id, wait) do
    GenServer.start_link(__MODULE__, {wait, id}, name: Sessions.session_name(id))
  end

  def join(id, user) do
    id |> Sessions.session_name() |> GenServer.cast({:join, user})
  end
end
