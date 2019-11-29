module Corbot
  module UserService
    require File.join(__dir__, "./user")
    require File.join(__dir__, "../refuge/client")

    ADMIN_IDS = ENV.fetch("ADMIN_IDS") { "" }

    def self.update_users_from_refuge(city_id)
      admin_ids = ADMIN_IDS.split(",").map(&:to_i)

      Corbot::User.transaction do
        Corbot::User.update_all(removed: true)

        Refuge::Client.search_users(city_id).each do |member|
          Corbot::User.where(refuge_user_id: member.id).first_or_initialize.tap do |user|
            user.refuge_user_first_name = member.first_name
            user.refuge_user_last_name = member.last_name
            user.admin = member.admin || admin_ids.include?(member.id)
            user.removed = false
            user.save
          end
        end
      end
    end

    def self.refresh_presence
      Corbot::User.transaction do
        Corbot::User.update_all(current_location_id: nil, located_at: DateTime.now())
        Refuge::Client.user_presences.each do |user|
          Corbot::User
            .where(refuge_user_id: user["id"])
            .update_all(current_location_id: user["current_location_id"])
        end
      end
    end

    def self.users
      Corbot::User.where(removed: false)
    end

    def self.users_by_location_id_with_slack_id(location_id)
      users
        .where(current_location_id: location_id)
        .where.not(slack_user_id: nil)
    end

    def self.users_by_location_id_without_slack_id(location_id)
      users
        .where(current_location_id: location_id)
        .where(slack_user_id: nil)
    end

    def self.users_without_slack_id
      users
        .where(slack_user_id: nil)
        .where(ignored: false)
    end

    def self.users_with_slack_id
      users
        .where.not(slack_user_id: nil)
        .where(ignored: false)
    end

    def self.admins_with_slack_id
      users
        .where(admin: true, ignored: false)
        .where.not(slack_user_id: nil)
    end

    def self.bind_user(refuge_user_id, slack_user_id)
      Corbot::User
        .where(refuge_user_id: refuge_user_id, removed: false)
        .update_all(
          slack_user_id: slack_user_id,
          bound_at: DateTime.now(),
        )
    end

    def self.cancel_last_bind
      users_with_slack_id
        .order(bound_at: :desc)
        .limit(1)
        .update_all(
          slack_user_id: nil,
          bound_at: nil,
        )
    end

    def self.ignore_bind(refuge_user_id)
      Corbot::User
        .where(refuge_user_id: refuge_user_id, removed: false)
        .update_all(ignored: true)
    end
  end
end
