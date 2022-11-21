# TODO: supervise

defmodule Edit do
  use Agent

  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(channel_id) do
    Agent.get(__MODULE__, & Map.get(&1, channel_id))
  end

  def put(channel_id, message) do
    Agent.update(__MODULE__, & Map.put(&1, channel_id, message))
  end


  # REMOVE WHEN DONE DEBUGGING
  def print_map do
    IO.inspect Agent.get(__MODULE__, & &1)
  end
end
