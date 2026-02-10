class AddBoostedUntilToListings < ActiveRecord::Migration[8.1]
  def change
    add_column :listings, :boosted_until, :datetime
  end
end
