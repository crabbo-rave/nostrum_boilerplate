defmodule EmojiRace.Racer do
  defstruct [:emoji, :user, done: 0]
end

defmodule EmojiRace.Race do
  use GenServer

  alias EmojiRace.Racer
  alias EmojiRace.Commands.Join

  @emojies ["🤣", "😁", "🙈", "🔥", "😎", "😱", "🤡", "🦀", "🍾", "🙃"] # FUTURE: get random emoji from server's emoji list

  def get_emoji(racers) do
    emojies = for emoji <- @emojies, do: %{name: emoji}
    racer_emojies = for %{emoji: e} <- racers, do: e
    Enum.random(Enum.filter(emojies, &(&1.name not in racer_emojies)))
  end

  @impl true
  def init({len, time, id}) do
    timer = Process.send_after(self(), {:end_wait, id}, time*1000)
    {:ok, %{timer: timer, length: len, joinable?: true, racers: []}}
  end

  @impl true
  def handle_call(:racers, _from, state) do
    {:reply, state.racers, state}
  end

  @impl true
  def handle_cast({:join, _}, %{joinable: false}), do: throw :cant_join_game # NOTE: maybe won't need this if i disable button
  def handle_cast({:join, user}, state) do
    prev_racers = Map.get(state, :racers)
    racers = [%Racer{user: user, emoji: get_emoji(prev_racers)} | prev_racers]
    {:noreply, %{state | racers: racers}}
  end

  @impl true # use id when doing discord stuff
  def handle_info({:end_wait, id}, state) do
    # Join.disable_join(id) # TODO: single process for now. reimplement as multiple processes.
    timer = Process.send_after(self(), {:move, id}, 1000)

    if Enum.count(state.racers) in [0,1] do
      throw :too_little_racers
    else
      {:noreply, %{state | joinable?: false, timer: timer}}
    end
  end

  def handle_info({:move, id}, state) do
    new_distances =
      state.racers
      |> Enum.map(fn racer -> %Racer{racer | done: racer.done + rem(:erlang.unique_integer([:positive]), 5)} end)

    IO.inspect new_distances

    if Enum.find(new_distances, fn racer -> racer.done == state.length end) != nil do
      IO.inspect "race done"

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
  def start_link(id, len, wait) do
    GenServer.start_link(__MODULE__, {len, wait, id}, name: session_name(id))
  end

  def join(id, user) do
    id |> session_name() |> GenServer.cast({:join, user})
  end

  # maybe remove with notifier
  def racers(id) do
    id |> session_name() |> GenServer.call(:racers)
  end

  def session_name(id) do
    {:via, Registry, {Registry.RaceRegistry, id}}
  end
end
