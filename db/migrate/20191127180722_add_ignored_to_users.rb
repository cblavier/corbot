class AddIgnoredToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :ignored, :boolean, default: false
  end
end
