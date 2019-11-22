module Record
  def record_request(request, name)
    file_path = "tmp/request-#{name}-#{Time.now().to_i}.json"
    request.body.rewind
    payload = { headers: request.env, body: request.body.read }
    File.open(file_path, "w") do |f|
      f.write(payload.to_json)
    end
  end
end
