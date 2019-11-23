module Refuge
  require "net/http"
  require "cgi"
  require "json"

  REFUGE_BASE_URL = "https://refuge.la-cordee.net"
  USE_SSL = true

  def get_refuge_profile(id, cookie)
    body = get("https://refuge.la-cordee.net/users/#{id}.json", cookie)
    JSON.parse(body)
  end

  def search_users(city_id, cookie)
    body = post(
      "https://refuge.la-cordee.net/users/search.json",
      { city_id: city_id, limit: 1000 },
      cookie
    )
    JSON.parse(body)
  end

  private

  def get(path, cookie)
    uri = URI.parse(path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = USE_SSL
    request = Net::HTTP::Get.new(uri.request_uri)
    request["Cookie"] = cookie
    r = http.request(request)
    r.body
  end

  def post(path, payload, cookie)
    uri = URI.parse(path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = USE_SSL
    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request.body = payload.to_json
    request["Cookie"] = cookie
    r = http.request(request)
    r.body
  end
end
