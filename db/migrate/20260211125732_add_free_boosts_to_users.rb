class AddFreeBoostsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :free_boosts_used, :integer, default: 0, null: false
    add_column :users, :free_boosts_reset_at, :datetime
  end
end
