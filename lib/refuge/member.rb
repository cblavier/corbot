module Refuge
  class Member < OpenStruct
    def self.from_json(json)
      self.new(
        id: json['id'].to_i,
        first_name: json['first_name'],
        last_name: json['last_name'],
        home: json['home'],
        created_at: (Date.parse(json['created_at']) unless json['created_at'].nil?) ,
        description: json['description'],
        description_1: json['description_1'],
        description_2: json['description_2'],
        description_3: json['description_3'],
        description_4: json['description_4'],
        admin: json['admin'],
        avatar: get_avatar(json),
        tags: get_tags(json)
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
