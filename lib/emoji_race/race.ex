defmodule EmojiRace.Racer do
  defstruct [:emoji, :user, done: 0]
end

# TODO: supervise instances with DynamicSupervisor
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

  # TODO: figure out how to not have the id field
  @impl true
  def init({len, time, id}) do
    timer = Process.send_after(self(), :end_wait, time*1000)
    {:ok, %{id: id, timer: timer, length: len, joinable?: true, racers: []}}
  end

  @impl true
  def handle_call(:racers, _from, state) do
    {:reply, state.racers, state}
  end

  def handle_call(:joinable?, _from, state) do
    {:reply, state.joinable?, state}
  end

  @impl true
  def handle_cast({:join, _}, %{joinable: false}), do: throw :cant_join_game # NOTE: maybe won't need this if i disable button
  def handle_cast({:join, user}, state) do
    prev_racers = Map.get(state, :racers)
    racers = [%Racer{user: user, emoji: get_emoji(prev_racers)} | prev_racers]
    {:noreply, %{state | racers: racers}}
  end

  @impl true
  def handle_info(:end_wait, state) do
    Join.disable_join(state.id)

    {:noreply, %{state | joinable?: false}}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  # API
  def start_link(id, len, wait) do
    GenServer.start_link(__MODULE__, {len, wait, id}, name: via_tuple(id))
  end

  def join(id, user) do
    id |> via_tuple() |> GenServer.cast({:join, user})
  end

  def racers(id) do
    id |> via_tuple() |> GenServer.call(:racers)
  end

  # maybe remove
  def joinable?(id) do
    id |> via_tuple() |> GenServer.call(:joinable?)
  end

  def via_tuple(id) do
    {:via, Registry, {Registry.RaceRegistry, id}}
  end
end
