module Slack
  # Module to open, update and interact with Slack modal views.
  module ModalPublisher
    require 'json'
    require 'net/http'
    require 'pp'

    def self.publish_profile_modal(user, user_profile, trigger_id)
      puts "Publishing profile modal of #{user_profile['first_name']} #{user_profile['last_name']}"
      slack_publish_url = 'https://slack.com/api/views.open'.freeze
      slack_bot_token = ENV['SLACK_BOT_TOKEN']
      payload = {
        trigger_id: trigger_id,
        view: Slack::ModalBuilder.profile_modal(user, user_profile)
      }
      response = post_json(slack_publish_url, slack_bot_token, payload)
      if response.code == '200'
        json = JSON.parse(response.body)
        if json['ok']
          puts 'ok'
          true
        else
          puts "error: #{json.inspect}"
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
  end
end
