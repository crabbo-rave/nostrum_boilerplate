defmodule EmojiRace.Consumer do
  @moduledoc false
  use Nostrum.Consumer

  alias EmojiRace.Commands

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:READY, _data, _ws_state}) do
    Commands.register_commands()
  end

  # pattern match for the custom id of the button
  def handle_event({:INTERACTION_CREATE, %{data: %{custom_id: "join_game"}} = interaction, _ws_state}) do
    EmojiRace.Commands.Join.join_game(interaction)
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
    Commands.handle_interaction(interaction)
  end

  def handle_event(_data) do
    :noop
  end
end
