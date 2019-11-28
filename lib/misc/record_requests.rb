module RecordRequests
  def self.record(request, name = "request")
    file_path = "tmp/request-#{name}-#{Time.now().to_i}.json"
    request.body.rewind
    payload = { headers: request.env, body: CGI::unescape(request.body.read) }
    File.open(file_path, "w") do |f|
      f.write(payload)
    end
  end
end
