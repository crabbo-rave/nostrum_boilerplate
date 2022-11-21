defmodule EmojiRace.Commands.Start do
  @moduledoc false
  @behaviour EmojiRace.Command

  alias Nostrum.Api
  alias Nostrum.Struct.Embed
  alias Nostrum.Struct.Component.ActionRow
  alias Nostrum.Struct.Component.Button
  alias EmojiRace.Command
  alias EmojiRace.Race

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

    {:ok, _} = Race.start_link(length, wait) # with channel id

    embed =
      %Embed{}
      |> Embed.put_title("Race") # put channel id in name
      |> Embed.put_description("Waiting for players...") # NOTE: maybe do a countdown?
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

    Edit.put(interaction.channel_id, message)

    Api.create_interaction_response(interaction, message)
  end
end
