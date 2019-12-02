module Slack
  module ModalBuilder
    require 'jbuilder'
    require_relative './blocks'
    include Slack::Blocks

    def self.profile_modal_404
      Jbuilder.new do |view|
        view.type 'modal'
        view.callback_id 'modal-profile'
        view.title do
          view.type 'plain_text'
          view.text 'Pas de profil ...'
        end
        render_blocks(view,
          [
            text_block("Oups, on dirait que je n'ai pas accès au profil de ce membre :tired_face:"),
            image_block(
              'https://gifimage.net/wp-content/uploads/2017/12/jhon-travolta-gif-1.gif',
              'Confused Travolta'
            )
          ]
        )
      end.target!
    end

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
            ':grinning:   Qui suis-je ?',
            button_block(
              'Voir sur le Refuge',
              "https://refuge.la-cordee.net/users/#{user.refuge_user_id}"
            )
          ),
          text_block(
            user_profile['description'].blank? ? '-' : user_profile['description'],
            image_block(user_profile['avatar'], 'Photo de profil')
          ),
          text_block("\n")
        ]

        unless user_profile['description_1'].blank?
          blocks += [
            title_blocks(':handshake:   Services'),
            text_block(user_profile['description_1'])
          ]
        end

        unless user_profile['description_2'].blank?
          blocks += [
            title_blocks(':open_file_folder:   Références'),
            text_block(user_profile['description_2'])
          ]
        end

        unless user_profile['description_3'].blank?
          blocks += [
            title_blocks(':game_die:   Hobbies'),
            text_block(user_profile['description_3'])
          ]
        end

        unless user_profile['description_4'].blank?
          blocks += [
            title_blocks(':zap:   Super pouvoirs'),
            text_block(user_profile['description_4'])
          ]
        end

        if user_profile['tags'].any?
          blocks += title_blocks(":star-struck:   Mes centres d'intérêt")
          tags = user_profile['tags'].map { |tag| "- #{tag}" }
          tags.each_slice(10) do |tag_slice|
            blocks += [fields_block(tag_slice)]
          end
        end

        blocks += [divider_block()]

        unless user_profile['home'].blank?
          blocks += [
            context_block(":house_with_garden: #{user_profile['home']}")
          ]
        end
        
        unless user_profile['created_at'].blank?
          created_at = DateTime.parse(user_profile['created_at'])
          blocks += [
            context_block("A rejoint la Cordée le #{created_at.strftime('%d %B %Y')}")
          ]
        end

        render_blocks(view, blocks)
      end.target!
    end
  end
end
