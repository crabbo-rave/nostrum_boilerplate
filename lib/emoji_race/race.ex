defmodule EmojiRace.Racer do
  defstruct [:emoji, :user, done: 0]
end

# TODO: supervise instances with DynamicSupervisor
# TODO: rewrite with registries
defmodule EmojiRace.Race do
  use GenServer

  alias EmojiRace.Racer

  @emojies ["🤣", "😁", "🙈", "🔥", "😎", "😱", "🤡", "🦀", "🍾", "🙃"]

  def get_emoji(racers) do
    emojies = for emoji <- @emojies, do: %{name: emoji}
    racer_emojies = for %{emoji: e} <- racers, do: e
    Enum.random(Enum.filter(emojies, &(&1.name not in racer_emojies)))
  end
  @impl true
  def init({len, time}) do
    timer = Process.send_after(self(), :end_wait, time*1000)
    {:ok, %{timer: timer, length: len, joinable: true, racers: []}}
  end

  @impl true
  def handle_call(:racers, _from, state) do
    {:reply, state, state}
  end

  @impl true
  # CHANGE FOR REGISTRY + channelid
  def handle_cast({:join, user}, state) do
    prev_racers = Map.get(state, :racers)
    racers = [%Racer{user: user, emoji: get_emoji(prev_racers)} | prev_racers]
    {:noreply, %{state | racers: racers}}
  end

  # in handle_info wait_done change joinable to false
  @impl true
  def handle_info(:end_wait, state) do
    {:noreply, %{state | joinable: false}}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  def start_link(len, wait) do
    GenServer.start_link(__MODULE__, {len, wait})
  end

  def join(server, user, emoji) do
    GenServer.cast(server, {:join, user, emoji})
  end
end
