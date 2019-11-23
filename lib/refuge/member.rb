module Refuge
  Member = Struct.new(:last_name,
                      :first_name,
                      :description,
                      :email,
                      :admin,
                      :avatar_url,
                      :tags)
end
