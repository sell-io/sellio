class CreateSellerFollows < ActiveRecord::Migration[8.1]
  def change
    create_table :seller_follows do |t|
      t.references :user, null: false, foreign_key: true
      t.references :seller, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :seller_follows, [:user_id, :seller_id], unique: true
  end
end
