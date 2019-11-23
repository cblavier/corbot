module Refuge
  module Client
    require "net/http"
    require "cgi"
    require "json"

    REFUGE_BASE_URL = "https://refuge.la-cordee.net"
    USE_SSL = true

    def self.get_refuge_profile(id, cookie)
      get("/users/#{id}", cookie)
    end

    def self.user_presences(cookie)
      get("/locations/user_presences", cookie)
    end

    def self.search_users(city_id, cookie, csrf)
      post("/users/search", { city_id: city_id, limit: 1000 }, cookie, csrf)
    end

    private

    def self.get(path, cookie)
      http_request(path, :get, cookie)
    end

    def self.post(path, payload, cookie, csrf)
      http_request(path, :post, cookie, csrf, payload)
    end

    def self.http_request(path, method, cookie, csrf = nil, payload = nil)
      uri = URI.parse(REFUGE_BASE_URL + path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = USE_SSL

      if method == :get
        request = Net::HTTP::Get.new(uri.request_uri)
      elsif method == :post
        request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
        request.body = payload.to_json
      else
        raise "Unknown HTTP method #{method}"
      end

      request["Cookie"] = cookie
      request["X-CSRF-Token"] = csrf unless csrf.nil?
      request["Accept"] = "application/json"
      request["User-Agent"] = "corbot"
      result = http.request(request)

      case result.code
      when /2\d{2}/ then JSON.parse(result.body)
      when "302" then raise "redirected (not found?)"
      when /40[1,3]/ then raise "unauthorized"
      when "404" then raise "not found"
      when /5\d{2}/ then raise "server error"
      else raise "unknow error"
      end
    end
  end
end
