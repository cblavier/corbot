module Corbot
  module UserService
    require File.join(__dir__, "./user")
    require File.join(__dir__, "../refuge/client")

    ADMIN_IDS = ENV.fetch("ADMIN_IDS") { "" }

    def self.update_users_from_refuge(city_id, cookie, csrf)
      admin_ids = ADMIN_IDS.split(",").map(&:to_i)

      Corbot::User.transaction do
        Corbot::User.update_all(removed: true)

        Refuge::Client.search_users(city_id, cookie, csrf).each do |member|
          Corbot::User.where(
            refuge_user_id: member.id,
            refuge_user_first_name: member.first_name,
            refuge_user_last_name: member.last_name,
            admin: member.admin || admin_ids.include?(member.id)
          ).first_or_create(removed: false)
        end
      end
    end

    def self.users_without_slack_id(limit = 1000)
      Corbot::User.where(slack_user_id: nil).limit(limit).to_a
    end

    def self.users_with_slack_id(limit = 1000)
      Corbot::User.where.not(slack_user_id: nil).limit(limit).to_a
    end

    def self.bind_user(refuge_user_id, slack_user_id, slack_user_name)
      Corbot::User
        .where(refuge_user_id: refuge_user_id)
        .update_all(
          slack_user_id: slack_user_id,
          slack_user_name: slack_user_name
        )
    end
  end
end
