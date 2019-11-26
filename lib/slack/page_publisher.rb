module Slack
  module PagePublisher

    require 'json'
    require 'net/http'

    SLACK_PUBLISH_URL = "https://slack.com/api/views.publish"
    SLACK_BOT_TOKEN = ENV["SLACK_BOT_TOKEN"]

    def self.republish_user_home_pages 
      Corbot::UserService.users_with_slack_id.each do |user|
        publish_home_page(user)
      end
    end

    def self.publish_home_page(user) 
      puts "Publishing page for #{user.full_name}"
      payload = {
        user_id: user.slack_user_id,
        view: Slack::PageBuilder.home_page_view(user)
      }
      response = post_json(SLACK_PUBLISH_URL, SLACK_BOT_TOKEN, payload)
      if response.code == "200"
        json = JSON.parse(response.body)
        if json["ok"] 
          puts "ok"
          true
        else
          puts "error: #{json["error"]}"
          false
        end
      else
        puts "error #{response.code}"
        false
      end
    end

    private

    def self.post_json(url, token, payload) 
      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(
        uri.path,
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{token}"
      )
      request.body = payload.to_json
      https.request(request)
    end

  end
end