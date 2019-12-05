module Refuge
  # Refuge location identifiers.
  module Locations
    def self.nantes_city_id
      8
    end

    def self.cordees_nantes_location_ids
      [
        cordee_foure_location_id,
        cordee_sur_erdre_location_id
      ]
    end

    def self.cordee_foure_location_id
      14
    end

    def self.cordee_sur_erdre_location_id
      16
    end
  end
end
