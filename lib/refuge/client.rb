module Refuge
  # HTTP Client for unoffical Refuge APIs.
  module Client
    require 'net/http'
    require 'cgi'
    require 'json'

    REFUGE_BASE_URL = 'https://refuge.la-cordee.net'.freeze
    USE_SSL = true

    def self.get_refuge_profile(id)
      json = get("/users/#{id}")
      json['id'] = id
      Refuge::Member.from_json(json).freeze
    rescue NotFoundError
      nil
    end

    def self.user_presences
      get('/locations/user_presences')
    end

    def self.search_users(city_id)
      json = post('/users/search', city_id: city_id, limit: 1000)
      json['users'].map do |member_json|
        Refuge::Member.from_json(member_json).freeze
      end
    end

    private_class_method def self.get(path)
      cookie = ENV['REFUGE_COOKIE']
      http_request(path, :get, cookie: cookie)
    end

    private_class_method def self.post(path, payload)
      cookie = ENV['REFUGE_COOKIE']
      csrf = ENV['REFUGE_CSRF']
      http_request(path, :post, cookie: cookie, csrf: csrf, payload: payload)
    end

    private_class_method def self.http_request(path, method, cookie:, csrf: nil, payload: nil)
      uri = URI.parse(REFUGE_BASE_URL + path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = USE_SSL

      if method == :get
        request = Net::HTTP::Get.new(uri.request_uri)
      elsif method == :post
        request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        request.body = payload.to_json
      else
        raise "Unknown HTTP method #{method}"
      end

      request = put_headers(request, cookie: cookie, csrf: csrf)
      response = http.request(request)
      handle_http_response(response)
    end

    private_class_method def self.put_headers(request, cookie:, csrf:)
      request['Cookie'] = cookie
      request['X-CSRF-Token'] = csrf unless csrf.nil?
      request['Accept'] = 'application/json'
      request['User-Agent'] = 'corbot'
      request
    end

    private_class_method def self.handle_http_response(response)
      case response.code
      when /2\d{2}/ then JSON.parse(response.body)
      when '302' then raise NotFoundError
      when /40[1,3]/ then raise UnauthorizedError
      when '404' then raise NotFoundError
      when /5\d{2}/ then raise 'server error'
      else raise 'unknow error'
      end
    end

    class NotFoundError < StandardError; end
    class UnauthorizedError < StandardError; end
  end
end
