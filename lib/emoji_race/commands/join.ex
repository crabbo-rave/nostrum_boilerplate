defmodule EmojiRace.Commands.Join do
  alias Nostrum.Struct.Component.TextInput
  alias Nostrum.Struct.Component.ActionRow
  alias Nostrum.Api

  # TODO: random emoji, no input modal
  def input_modal(interaction) do
    text_input = TextInput.text_input("Emoji", "emoji_input")

    IO.inspect Api.create_interaction_response(interaction, %{
      type: 9,
      data: %{
        title: "Enter your emoji",
        custom_id: "join_modal",
        components: [
          ActionRow.action_row() |> ActionRow.put(text_input)
        ]
      }
    })
  end
end
