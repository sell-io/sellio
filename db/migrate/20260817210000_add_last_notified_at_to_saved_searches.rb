class AddLastNotifiedAtToSavedSearches < ActiveRecord::Migration[8.1]
  def change
    add_column :saved_searches, :last_notified_at, :datetime
  end
end
