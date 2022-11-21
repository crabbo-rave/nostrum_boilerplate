defmodule EmojiRace.Commands.Join do
  alias Nostrum.Api

  # TODO: random emoji, no input modal
  def join_game(interaction) do
    prev_message = Edit.get(interaction.channel_id)

    # Edit.print_map()

    emoji = %{name: "🤣"} # TODO: get_emoji with Race + Registry

    new_desc = Enum.at(prev_message[:data][:embeds], 0).description <> "#{interaction.user.username} joined as #{emoji.name}"

    # IO.inspect Enum.at(prev_message[:data][:embeds], 0).description

    # IO.inspect new_desc

    # FIXME: not editing interaction
    Api.edit_interaction_response(interaction, put_in(Enum.at(prev_message[:data][:embeds], 0).description, new_desc))
  end
end
