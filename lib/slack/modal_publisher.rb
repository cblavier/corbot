module Slack
  # Module to open, update and interact with Slack modal views.
  module ModalPublisher
    require_relative './publish_client'

    def self.publish_profile_modal_404(trigger_id)
      Slack::PublishClient.publish_view(
        'https://slack.com/api/views.open',
        trigger_id: trigger_id,
        view: Slack::ModalBuilder.profile_modal_404
      )
    end

    def self.publish_profile_modal(user, user_profile, trigger_id)
      Slack::PublishClient.publish_view(
        'https://slack.com/api/views.open',
        trigger_id: trigger_id,
        view: Slack::ModalBuilder.profile_modal(user, user_profile)
      )
    end
  end
end
