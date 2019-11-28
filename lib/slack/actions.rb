module Slack
  module Actions
    def self.perform(action)
      case action["action_id"]
      when /bind_user_(.*)/
        async_bind_user($1, action["selected_user"])
      when "admin_overflow"
        case action["selected_option"]["value"]
        when "cancel_last_bind"
          async_cancel_last_bind()
        when /ignore_bind_(.*)/
          async_ignore_bind($1)
        end
      end
    end

    private

    def self.async_bind_user(refuge_user_id, slack_user_id) 
      Thread.new do
        Corbot::UserService.bind_user(refuge_user_id, slack_user_id)
        Slack::PagePublisher.republish_admin_home_pages()
      end
    end

    def self.async_cancel_last_bind() 
      Thread.new do
        Corbot::UserService.cancel_last_bind()
        Slack::PagePublisher.republish_admin_home_pages()
      end
    end

    def self.async_ignore_bind(refuge_user_id) 
      Thread.new do
        Corbot::UserService.ignore_bind(refuge_user_id)
        Slack::PagePublisher.republish_admin_home_pages()
      end
    end
  end
end