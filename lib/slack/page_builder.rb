module Slack
  module PageBuilder
    require "jbuilder"

    def self.home_page_view(user)
      user_service = Corbot::UserService
      Jbuilder.new do |view|
        view.type "home"
        blocks = [
          text_block("Bonjour *#{user.first_name}* ! :smile:"),
          text_block("\n"),
        ]
        if user.admin
          total_count = user_service.users.count
          bound_count = user_service.users_with_slack_id.count
          user_to_bind = user_service.users_without_slack_id.first

          blocks = blocks + [
            title_blocks("Administration"),
            text_block(
              "Il y a *#{total_count} membres* du Refuge dont *#{bound_count}* avec un compte Slack connu.",
              overflow("admin_overflow", [
                { label: "Ignorer ce membre.", value: "ignore_bind_#{user_to_bind.try(:refuge_user_id)}" },
                { label: "Annuler la dernière association.", value: "cancel_last_bind" },
              ])
            ),
          ]
          if user_to_bind
            user_to_bind_count = user_service.users_without_slack_id.count
            blocks = blocks + [
              text_block(
                "Voici le premier membre des *#{user_to_bind_count}* dont le compte Slack est inconnu :",
              ),
              text_block(
                "Indiquer quel est le compte Slack de #{user_to_bind.full_name}",
                user_select_blocks(
                  "Choisir un compte",
                  "bind_user_#{user_to_bind.refuge_user_id}"
                )
              ),
            ]
          end
        end
        render_blocks(view, blocks)
      end.target!
    end

    private

    def self.render_blocks(view, blocks)
      view.blocks blocks.flatten do |block|
        view.type block[:type]
        %I(text accessory elements options).each do |key|
          if block[key]
            view.set! key do
              view.merge!(block[key])
            end
          end
        end
      end
    end

    def self.title_blocks(title)
      [
        text_block("*#{title}*"),
        { type: "divider" },
      ]
    end

    def self.text_block(markdown, accessory = nil)
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: markdown,
        },
        accessory: accessory,
      }
    end

    def self.user_select_blocks(placeholder, action_id, accessory = nil)
      {
        type: "users_select",
        action_id: action_id,
        placeholder: {
          type: "plain_text",
          text: placeholder,
          emoji: true,
        },
      }
    end

    def self.overflow(action_id, actions)
      {
        type: "overflow",
        action_id: action_id,
        options: actions.map do |action|
          {
            text: { type: "plain_text", text: action[:label] },
            value: action[:value],
          }
        end,
      }
    end
  end
end
