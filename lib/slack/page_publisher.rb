module Slack
  # App home tab publication.
  module PagePublisher
    require_relative './publish_client'

    def self.republish_user_home_pages
      Corbot::UserService
        .users_with_slack_id
        .map { |user| publish_home_page(user) }
        .count(&:itself)
    end

    def self.republish_admin_home_pages
      Corbot::UserService
        .admins_with_slack_id
        .map { |user| publish_home_page(user) }
        .count(&:itself)
    end

    def self.publish_home_page(user)
      puts "Publishing page for #{user.full_name}"
      Slack::PublishClient.publish_view(
        'https://slack.com/api/views.publish',
        user_id: user.slack_user_id,
        view: Slack::PageBuilder.home_page_view(user)
      )
    end
  end
end
