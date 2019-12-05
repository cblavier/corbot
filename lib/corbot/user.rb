module Corbot
  # Corbot user model, which stores Refuge user attributes,
  # Slack identifiers and corbot state features.
  class User < ActiveRecord::Base
    def first_name 
      refuge_user_first_name
    end

    def last_name 
      refuge_user_last_name
    end

    def full_name
      "#{first_name} #{last_name}"
    end
  end
end
