defmodule EmojiRace.Racer do
  defstruct [:emoji, done: 0]
end

defmodule EmojiRace.Race do
  use GenServer

  alias EmojiRace.Racer

  def emojies do
    for emoji <- ["🤣", "😁", "🙈", "🔥", "😎", "😱", "🤡", "🦀", "🍾", "🙃"], do: %{ name: emoji }
  end

  @impl true
  # add joinable value to true
  def init({len, time}) do
    timer = Process.send_after(self(), :end_wait, time)
    {:ok, %{timer: timer, length: len, joinable: true, racers: %{}}}
  end

  @impl true
  # TODO: :winner
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl true
  # TODO: move
  def handle_cast({:join, user, emoji}, state) do
    racers = Map.put(Map.get(state, :racers), user, %Racer{emoji: emoji})
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
