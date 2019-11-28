module Slack
  module Security
    SLACK_VERSION_NB = "v0"

    def self.authenticate?(headers, body)
      slack_signing_secret = ENV["SLACK_SIGNING_SECRET"]
      timestamp = headers["HTTP_X_SLACK_REQUEST_TIMESTAMP"]
      sig_basestring = "#{SLACK_VERSION_NB}:#{timestamp}:#{body}"
      digest = OpenSSL::HMAC.hexdigest("SHA256", slack_signing_secret, sig_basestring)
      digest = "#{SLACK_VERSION_NB}=#{digest}"
      headers["HTTP_X_SLACK_SIGNATURE"] == digest
    end
  end
end
