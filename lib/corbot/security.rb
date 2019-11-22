module Security
  def authenticate?(headers, body, settings)
    signature = headers["HTTP_X_SLACK_SIGNATURE"]
    timestamp = headers["HTTP_X_SLACK_REQUEST_TIMESTAMP"]
    sig_basestring = "#{settings.slack_version_nb}:#{timestamp}:#{body}"
    digest = OpenSSL::HMAC.hexdigest("SHA256", settings.slack_signing_secret, sig_basestring)
    digest = "#{settings.slack_version_nb}=#{digest}"
    signature == digest
  end
end
