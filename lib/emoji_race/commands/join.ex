# TODO: move join out of commands

defmodule EmojiRace.Commands.Join do
  alias Nostrum.Api
  alias Nostrum.Struct.Component.ActionRow
  alias EmojiRace.Race
  alias EmojiRace.Edit

  # FIXME: not disabling button. wrong interaction still. CRASHES?!
  def disable_join(channel_id) do
    interaction = Edit.get_interaction(channel_id)
    message = Edit.get_message(channel_id)

    IO.inspect interaction

    new_comp =
      Enum.at(message[:data][:components], 0).components
      |> Enum.at(0)
      # |> Button.disable
      |> Map.put(:disabled, true)

    new_resp = %{
      type: 7,
      data: %{
        embeds: message[:data][:embeds],
        components: [
          ActionRow.action_row() |> ActionRow.append(new_comp)
        ]
      }
    }

    if Enum.count(Race.racers(interaction.channel_id)) in [0, 1] do
      throw :todo # delete the game message
    else
      Edit.put_message(interaction.channel_id, new_resp)

      Api.create_interaction_response(interaction, new_resp)
    end
  end

  def join_game(interaction) do
    edit_message = Edit.get_message(interaction.channel_id)

    emoji = Race.racers(interaction.channel_id) |> Race.get_emoji()

    if String.contains?(Enum.at(edit_message[:data][:embeds], 0).description, "#{interaction.user.id}") do
      throw :user_already_joined
    end

    new_desc = Enum.at(edit_message[:data][:embeds], 0).description <> "\n<@#{interaction.user.id}> joined as #{emoji.name}"

    new_embed =
      Enum.at(edit_message[:data][:embeds], 0).description
      |> put_in(new_desc)

    new_resp = %{
      type: 7,
      data: %{
        embeds: [new_embed],
        components: edit_message[:data][:components]
      }
    }

    Edit.put_message(interaction.channel_id, new_resp)
    Edit.put_interaction(interaction.channel_id, interaction)

    Api.create_interaction_response(interaction, new_resp)
  end
end
