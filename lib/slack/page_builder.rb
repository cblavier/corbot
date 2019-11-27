module Slack
  module PageBuilder

    require 'jbuilder'

    def self.home_page_view(user)
      user_service = Corbot::UserService
      Jbuilder.new do |view|
        view.type "home"
        blocks = [
          text_block("Bonjour *#{user.first_name}* ! :smile:"),
          text_block("\n")
        ]
        if user.admin      
          blocks = blocks + [
            title_blocks("Administration"),
            text_block("Il y a *#{user_service.users.count} membres* du Refuge dont *#{user_service.users_with_slack_id.count}* avec un compte Slack connu.")
          ]
          if user_to_bind = user_service.users_without_slack_id.first 
            blocks = blocks + [
              user_select_blocks(
                "Voici le premier des *#{user_service.users_without_slack_id.count}* restant à associer :",
                user_to_bind.full_name
              )
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
        if block[:text]
          view.text do
            view.merge!(block[:text]) 
          end
        end
        if block[:accessory]
          view.accessory do
            view.merge!(block[:accessory]) 
          end
        end
      end 
    end

    def self.title_blocks(title)
      [
        text_block("*#{title}*"),
        { type: "divider" }
      ]
    end

    def self.text_block(markdown)
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: markdown
        }
      }
    end

    def self.user_select_blocks(label, placeholder) 
      {
        type: "section",
			  text: {
				  type: "mrkdwn",
          text: label
        },
        accessory: {
          type: "users_select",
          placeholder: {
            type: "plain_text",
            text: placeholder,
            emoji: true
          }
        }
      }
    end

 

  end
end