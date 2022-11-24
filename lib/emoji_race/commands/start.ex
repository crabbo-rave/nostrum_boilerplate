defmodule EmojiRace.Commands.Start do
  @moduledoc false
  @behaviour EmojiRace.Command

  alias Nostrum.Api
  alias Nostrum.Struct.Embed
  alias Nostrum.Struct.Component.ActionRow
  alias Nostrum.Struct.Component.Button
  alias EmojiRace.Command
  alias EmojiRace.Race
  alias EmojiRace.Edit

  @impl Command
  def spec(name) do
    %{
      name: name,
      description: "Starts a race",
      options: [
        %{
          type: 4,
          name: "length",
          description: "Length of the race",
          required: true
        },
        %{
          type: 4,
          name: "wait",
          description: "Waiting room time in seconds",
          required: true
        }
      ]
    }
  end

  @impl Command
  def handle_interaction(interaction) do
    %{value: length} = Command.get_option(interaction, "length")
    %{value: wait} = Command.get_option(interaction, "wait")

    embed =
      %Embed{}
      |> Embed.put_title("Race")
      |> Embed.put_description("In <\##{interaction.channel_id}>\nWaiting for players...") # TODO: do a countdown
      |> Embed.put_color(16_776_960)

    # disable when timer runs out
    join =
      Button.interaction_button("Join", "join_game", required: true, emoji: %{ name: "🤣" })

    message = %{
      type: 4,
      data: %{
        embeds: [
          embed
        ],
        components: [
          ActionRow.action_row() |> ActionRow.append(join)
        ]
      }
    }

    # Edit.put_message(interaction.channel_id, %{message | type: 7})
    # Edit.put_interaction(interaction.channel_id, interaction)

    # IO.inspect interaction

    # Api.create_interaction_response(interaction, message)

    case Race.start_link(interaction.channel_id, length, wait) do
      {:ok, _} ->
        Edit.put_message(interaction.channel_id, %{message | type: 7})
        Edit.put_interaction(interaction.channel_id, interaction)

        Api.create_interaction_response(interaction, message)
      {:error, _} ->
        %{id: id, channel_id: channel_id, guild_id: guild_id} = Edit.get_interaction(interaction.channel_id)

        error_message = %{
          type: 4,
          data: %{
            embeds: [
              %Embed{}
              |> Embed.put_title("Game already started in channel")
              |> Embed.put_description("Game started in <\##{channel_id}>\nJoin the [race](https://discord.com/channels/#{guild_id}/#{channel_id}/#{id})")
              |> Embed.put_color(16_776_960)
            ]
          }
        }

        Api.create_interaction_response(interaction, error_message) # TODO: maybe delete after 5 seconds
    end
  end
end
