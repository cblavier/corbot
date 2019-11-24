class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :refuge_user_id, null: false
      t.string :refuge_user_first_name, null: false
      t.string :refuge_user_last_name, null: false
      t.string :slack_user_id
      t.string :slack_user_name
      t.boolean :removed, default: false
      t.timestamps
    end
  end
end
