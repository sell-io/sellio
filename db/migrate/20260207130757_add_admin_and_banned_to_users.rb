class AddAdminAndBannedToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :admin, :boolean, default: false, null: false
    add_column :users, :banned_at, :datetime
  end
end
