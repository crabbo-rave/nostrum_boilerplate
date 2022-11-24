# TODO: supervise
# TODO: maybe rewrite

defmodule EmojiRace.Edit do
  use Agent

  def start_link() do
    Agent.start_link(fn -> %{messages: %{}, interactions: %{}} end, name: __MODULE__)
  end

  def get_message(channel_id) do
    Agent.get(__MODULE__, & Map.get(&1, :messages) |> Map.get(channel_id))
  end

  def put_message(channel_id, message) do
    new_message =
      Agent.get(__MODULE__, & Map.get(&1, :messages))
      |> Map.put(channel_id, message)
    Agent.update(__MODULE__, & Map.put(&1, :messages, new_message))
  end

  def get_interaction(channel_id) do
    Agent.get(__MODULE__, & Map.get(&1, :interactions) |> Map.get(channel_id))
  end

  def put_interaction(channel_id, interaction) do
    new_interaction =
      Agent.get(__MODULE__, & Map.get(&1, :interactions))
      |> Map.put(channel_id, interaction)
    Agent.update(__MODULE__, & Map.put(&1, :interactions, new_interaction))
  end
end
