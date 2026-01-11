class AddCategoryAndUserToListings < ActiveRecord::Migration[8.1]
  def change
    # Add category_id if it doesn't exist
    unless column_exists?(:listings, :category_id)
      add_reference :listings, :category, null: true, foreign_key: true
    end
    
    # Add user_id if it doesn't exist
    unless column_exists?(:listings, :user_id)
      add_reference :listings, :user, null: true, foreign_key: true
    end
    
    # Add indexes for better performance
    add_index :listings, :category_id unless index_exists?(:listings, :category_id)
    add_index :listings, :user_id unless index_exists?(:listings, :user_id)
  end
end
