module Corbot
  class User < ActiveRecord::Base

    def first_name 
      self.refuge_user_first_name
    end

    def last_name 
      self.refuge_user_last_name
    end

    def full_name
      "#{self.first_name} #{self.last_name}"
    end
  end
end
