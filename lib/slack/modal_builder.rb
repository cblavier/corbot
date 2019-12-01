module Slack
  module ModalBuilder
    require 'jbuilder'
    require_relative './blocks'
    include Slack::Blocks

    def self.profile_modal(user, user_profile)
      full_name = "#{user_profile['first_name']} #{user_profile['last_name']}"
      Jbuilder.new do |view|
        view.type 'modal'
        view.callback_id 'modal-profile'
        view.title do
          view.type 'plain_text'
          view.text full_name.first(24)
        end

        blocks = [
          title_blocks(
            ':grinning: - Qui suis-je ?',
            button_block(
              'Voir sur le Refuge',
              "https://refuge.la-cordee.net/users/#{user.refuge_user_id}"
            )
          ),
          text_block(
            user_profile['description'],
            image_block(user_profile['avatar'], 'Photo de profil')
          ),
          text_block("\n")
        ]

        if user_profile['tags'].any?
          blocks += title_blocks(":game_die: - Mes centres d'intérêt")
          tags = user_profile['tags'].map { |tag| "- #{tag}" }
          tags.each_slice(10) do |tag_slice|
            blocks += [fields_block(tag_slice)]
          end
        end

        render_blocks(view, blocks)
      end.target!
    end
  end
end
