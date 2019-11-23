module Refuge
  class Member < OpenStruct
    def self.from_json(json)
      self.new(
        id: json["id"].to_i,
        first_name: json["first_name"],
        last_name: json["last_name"],
        description: json["description"],
        email: json["email"],
        admin: json["admin"],
        avatar: get_avatar(json),
        tags: get_tags(json),
      )
    end

    def self.get_avatar(json)
      json["avatar"] ? json["avatar"]["url"] : nil
    end

    def self.get_tags(json)
      json["tags"] ? json["tags"].map { |tag| tag["name"] } : []
    end
  end
end
