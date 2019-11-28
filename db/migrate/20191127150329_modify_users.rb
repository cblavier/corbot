class ModifyUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :bound_at, :datetime
    remove_column :users, :slack_user_name, :string
  end
end
