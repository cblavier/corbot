module Slack
  # Wrapper around page and modal Slack publication API.
  module PublishClient
    require 'json'
    require 'net/http'

    def self.publish_view(url, payload)
      response = post_json(url, ENV['SLACK_BOT_TOKEN'], payload)
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
  end
end
