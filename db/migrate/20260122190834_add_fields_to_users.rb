class AddFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
  change_table :users do |t|
    t.integer  :sign_in_count, default: 0, null: false
    t.datetime :current_sign_in_at
    t.datetime :last_sign_in_at
    t.string   :current_sign_in_ip
    t.string   :last_sign_in_ip
  end
  remove_column :users, :email_address, :string
  add_column :users, :email, :string
  end
end
