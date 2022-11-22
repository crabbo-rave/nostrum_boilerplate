defmodule EmojiRace.Commands.Join do
  alias Nostrum.Api

  def join_game(interaction) do
    edit_message = Edit.get(interaction.channel_id)

    emoji = %{name: "🤣"} # TODO: get_emoji with Race + Registry

    new_desc = Enum.at(edit_message[:data][:embeds], 0).description <> "\n<@#{interaction.user.id}> joined as #{emoji.name}"

    # works but interaction fails: Api.edit_message(edit_message, embeds: [put_in(Enum.at(edit_message[:data][:embeds], 0).description, new_desc)])

    new_embed = put_in(Enum.at(edit_message[:data][:embeds], 0).description, new_desc)

    new_resp = %{
      type: 7,
      data: %{
        embeds: [new_embed],
        components: edit_message[:data][:components]
      }
    }

    # IO.inspect new_resp

    Api.create_interaction_response(interaction, new_resp)
  end
end
