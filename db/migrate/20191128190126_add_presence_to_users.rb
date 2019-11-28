class AddPresenceToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :current_location_id, :string
    add_column :users, :located_at, :datetime
  end
end
