module Slack
  # This module handles Slack Interactive actions.
  module Actions
    def self.perform_action(action)
      case action['action_id']
      when /bind_user_(.*)/
        async_bind_user($1, action['selected_user'])
      when 'admin_overflow'
        case action['selected_option']['value']
        when 'cancel_last_bind'
          async_cancel_last_bind
        when /ignore_bind_(.*)/
          async_ignore_bind($1)
        end
      end
    end

    def self.perform_message_action(action, trigger_id:, message:)
      case action
      when 'view_profile'
        async_view_profile(trigger_id, message)
      end
    end

    private_class_method def self.async_bind_user(refuge_user_id, slack_user_id)
      Thread.new do
        Corbot::UserService.bind_user(refuge_user_id, slack_user_id)
        Slack::PagePublisher.republish_admin_home_pages
        user = Corbot::User.find_by(refuge_user_id: refuge_user_id)
        Slack::PagePublisher.publish_home_page(user)
      end
    end

    private_class_method def self.async_cancel_last_bind
      Thread.new do
        Corbot::UserService.cancel_last_bind
        Slack::PagePublisher.republish_admin_home_pages
      end
    end

    private_class_method def self.async_ignore_bind(refuge_user_id)
      Thread.new do
        Corbot::UserService.ignore_bind(refuge_user_id)
        Slack::PagePublisher.republish_admin_home_pages
      end
    end

    private_class_method def self.async_view_profile(trigger_id, message)
      Thread.new do
        if (user = Corbot::User.where(slack_user_id: message['user']).first)
          if (profile = Refuge::Client.get_refuge_profile(user.refuge_user_id))
            Slack::ModalPublisher.publish_profile_modal(user, profile, trigger_id)
          else
            Slack::ModalPublisher.publish_profile_modal_404(trigger_id)
          end
        else
          Slack::ModalPublisher.publish_profile_modal_404(trigger_id)
        end
      end
    end
  end
end
