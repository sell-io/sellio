class CreatePendingPayments < ActiveRecord::Migration[8.1]
  def change
    create_table :pending_payments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false
      t.references :listing, null: true, foreign_key: true
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :consumed_at

      t.timestamps
    end

    add_index :pending_payments, :token, unique: true
  end
end
