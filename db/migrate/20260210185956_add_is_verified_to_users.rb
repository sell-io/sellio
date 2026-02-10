class AddIsVerifiedToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :is_verified, :boolean, default: false, null: false
  end
end
