module Slack
  module PageBuilder

    require 'jbuilder'

    def self.home_page_view(user)
      Jbuilder.new do |view|
        view.type "home"
        render_blocks(view, [
          text_block("Bonjour *#{user.first_name}* ! :smile:"),
          text_block("\n"),
          title_blocks("Admin")
        ])
      end.target!
    end

    private

    def self.render_blocks(view, blocks)
      view.blocks blocks.flatten do |block|
        view.type block[:type]
        if block[:text]
          view.text do
            view.type block[:text][:type]
            view.text block[:text][:text]
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

  end
end