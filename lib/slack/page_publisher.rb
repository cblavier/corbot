module Slack
  module PagePublisher
    require 'json'
    require 'net/http'
    require 'pp'

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
      payload = {
        user_id: user.slack_user_id,
        view: Slack::PageBuilder.home_page_view(user)
      }
      response = post_json(slack_publish_url, slack_bot_token, payload)
      if response.code == '200'
        json = JSON.parse(response.body)
        if json['ok'] 
          puts 'ok'
          true
        else
          puts "error: #{json['error']}"
          PP.pp JSON.parse(payload[:view])
          false
        end
      else
        puts "error #{response.code}"
        false
      end
    end

    private_class_method def self.post_json(url, token, payload)
      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(
        uri.path,
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{token}"
      )
      request.body = payload.to_json
      https.request(request)
    end

    def self.slack_publish_url
      'https://slack.com/api/views.publish'.freeze
    end

    def self.slack_bot_token
      ENV['SLACK_BOT_TOKEN']
    end
  end
end
