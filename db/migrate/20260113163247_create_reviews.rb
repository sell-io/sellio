class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.references :reviewed_user, null: false, foreign_key: { to_table: :users }
      t.integer :rating, null: false
      t.text :comment

      t.timestamps
    end
    
    add_index :reviews, [:reviewer_id, :reviewed_user_id], unique: true
    add_check_constraint :reviews, "rating >= 1 AND rating <= 5", name: "rating_range"
  end
end
