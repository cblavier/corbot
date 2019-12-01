module Slack
  # Slack::PageBuilder allows to build Slack blocks.
  # https://api.slack.com/reference/block-kit/blocks
  module Blocks
    def self.included base
      base.extend ClassMethods
    end

    # Class methods
    module ClassMethods

      def render_blocks(view, blocks)
        view.blocks blocks.flatten do |block|
          view.type block[:type]
          %I[text accessory elements options fields image_url alt_text].each do |key|
            next unless block[key]

            view.set! key do
              view.merge!(block[key])
            end
          end
        end
      end

      def title_blocks(title, accessory = nil)
        [
          text_block("*#{title}*", accessory),
          { type: 'divider' }
        ]
      end

      def text_block(markdown, accessory = nil)
        {
          type: 'section',
          text: { type: 'mrkdwn', text: markdown },
          accessory: accessory
        }
      end

      def context_block(markdown)
        {
          type: 'context',
          elements: [{ type: 'mrkdwn', text: markdown }]
        }
      end

      def user_select_blocks(placeholder, action_id)
        {
          type: 'users_select',
          action_id: action_id,
          placeholder: { type: 'plain_text', text: placeholder, emoji: true }
        }
      end

      def overflow(action_id, actions)
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

      def image_block(url, alt)
        { type: 'image', image_url: url, alt_text: alt }
      end

      def fields_block(fields)
        {
          type: 'section',
          fields: fields.map do |f|
            { type: 'plain_text', text: f, emoji: true }
          end
        }
      end

      def button_block(label, url) 
        {
          type: 'button',
          text: {
            type: 'plain_text',
            text: label
          },
          url: url
        }
      end

      def display_user(user)
        if user.slack_user_id
          "<@#{user.slack_user_id}>"
        else
          user.first_name
        end
      end

      def n(count, singular, plural = nil)
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
end
