module Slack
  # Slack::PageBuilder allows to build JSON Slack pages and blocks.
  # https://api.slack.com/reference/block-kit/blocks
  module PageBuilder
    require 'jbuilder'
    require_relative './blocks'
    
    include Slack::Blocks

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
              { label: 'Annuler la dernière action.', value: 'cancel_last_bind' },
              { label: 'Associer les membres ignorés.', value: 'unignore_users' }
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
  end
end
