module Refuge
  module Client
    require "net/http"
    require "cgi"
    require "json"

    REFUGE_BASE_URL = "https://refuge.la-cordee.net"
    USE_SSL = true

    def self.get_refuge_profile(id, cookie)
      body = get("/users/#{id}.json", cookie)
      JSON.parse(body)
    end

    def self.search_users(city_id, cookie, csrf)
      payload = { city_id: city_id, limit: 1000 }
      body = post("/users/search.json", payload, cookie, csrf)
      JSON.parse(body)
    end

    def self.user_presences(cookie)
      body = get("/locations/user_presences.json", cookie)
      JSON.parse(body)
    end

    private

    def self.get(path, cookie)
      uri = URI.parse(REFUGE_BASE_URL + path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = USE_SSL
      request = Net::HTTP::Get.new(uri.request_uri)
      request["Cookie"] = cookie
      r = http.request(request)
      r.body
    end

    def self.post(path, payload, cookie, csrf)
      uri = URI.parse(REFUGE_BASE_URL + path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = USE_SSL
      request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
      request.body = payload.to_json
      request["Cookie"] = cookie
      request["x-csrf-token"] = csrf
      r = http.request(request)
      r.body
    end
  end
end
