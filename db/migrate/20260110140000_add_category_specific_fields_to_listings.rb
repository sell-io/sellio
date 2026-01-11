class AddCategorySpecificFieldsToListings < ActiveRecord::Migration[8.1]
  def change
    # Add JSON column for flexible category-specific fields
    add_column :listings, :extra_fields, :jsonb, default: {}
    
    # Add index for JSON queries
    add_index :listings, :extra_fields, using: :gin
  end
end
