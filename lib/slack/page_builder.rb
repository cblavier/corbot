module Slack
  # Slack::PageBuilder allows to build JSON Slack pages and blocks.
  # https://api.slack.com/reference/block-kit/blocks
  module PageBuilder
    require 'jbuilder'

    def self.home_page_view(user)
      Jbuilder.new do |view|
        view.type 'home'
        blocks = [
          text_block("Bonjour *#{user.first_name}* ! :smile:"),
          text_block("\n"),
          location_blocks('Cordée Fouré', Refuge::Locations.cordee_foure_location_id),
          location_blocks('Cordée sur Erdre', Refuge::Locations.cordee_sur_erdre_location_id)
        ]
        blocks += build_admin_blocks if user.admin
        render_blocks(view, blocks)
      end.target!
    end

    private_class_method def self.location_blocks(location_name, location_id)
      users = Corbot::UserService.users_by_location_id(location_id)
      blocks = [
        title_blocks(location_name),
        text_block(
          "*#{n(users.count, 'membre* est présent', 'membres* sont présents')} à la *#{location_name}* :"
        )
      ]

      if users.any?
        refresh_date =
          users
          .order(located_at: :asc).first
          .located_at.in_time_zone('Europe/Paris').strftime('%H:%M:%S')

        blocks += [
          text_block(users.map { |u| display_user(u) }.join(', ')),
          context_block("Mis à jour à #{refresh_date}")
        ]
      end

      blocks + [text_block("\n")]
    end

    private_class_method def self.build_admin_blocks
      total_count = Corbot::UserService.users.count
      bound_count = Corbot::UserService.users_with_slack_id.count
      user = Corbot::UserService.users_without_slack_id.first

      blocks = [
        title_blocks('Administration'),
        text_block(
          "Il y a *#{n(total_count, 'membre')}* du Refuge dont *#{bound_count}* avec un compte Slack connu.",
          overflow(
            'admin_overflow',
            [
              { label: 'Ignorer ce membre.', value: "ignore_bind_#{user.try(:refuge_user_id)}" },
              { label: 'Annuler la dernière action.', value: 'cancel_last_bind' }
            ]
          )
        )
      ]
      blocks += build_user_binding_blocks(user) if user
      blocks
    end

    private_class_method def self.build_user_binding_blocks(user)
      user_to_bind_count = Corbot::UserService.users_without_slack_id.count
      [
        text_block(
          "Voici le premier membre des *#{user_to_bind_count}* dont le compte Slack est inconnu :"
        ),
        text_block(
          "Indiquer quel est le compte Slack de #{user.full_name}",
          user_select_blocks(
            'Choisir un compte',
            "bind_user_#{user.refuge_user_id}"
          )
        )
      ]
    end

    private_class_method def self.render_blocks(view, blocks)
      view.blocks blocks.flatten do |block|
        view.type block[:type]
        %I[text accessory elements options].each do |key|
          next unless block[key]

          view.set! key do
            view.merge!(block[key])
          end
        end
      end
    end

    private_class_method def self.title_blocks(title)
      [
        text_block("*#{title}*"),
        { type: 'divider' }
      ]
    end

    private_class_method def self.text_block(markdown, accessory = nil)
      {
        type: 'section',
        text: { type: 'mrkdwn', text: markdown },
        accessory: accessory
      }
    end

    private_class_method def self.context_block(markdown)
      {
        type: 'context',
        elements: [{ type: 'mrkdwn', text: markdown }]
      }
    end

    private_class_method def self.user_select_blocks(placeholder, action_id)
      {
        type: 'users_select',
        action_id: action_id,
        placeholder: { type: 'plain_text', text: placeholder, emoji: true }
      }
    end

    private_class_method def self.overflow(action_id, actions)
      {
        type: 'overflow',
        action_id: action_id,
        options: actions.map do |action|
          {
            text: { type: 'plain_text', text: action[:label] },
            value: action[:value]
          }
        end
      }
    end

    private_class_method def self.display_user(user)
      if user.slack_user_id
        "<@#{user.slack_user_id}>"
      else
        user.first_name
      end
    end

    private_class_method def self.n(count, singular, plural = nil)
      if count == 1
        "1 #{singular}"
      elsif plural
        "#{count} #{plural}"
      else
        "#{count} #{singular}s"
      end
    end
  end
end
