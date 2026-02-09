class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :reason, null: false
      t.text :body
      t.string :status, default: "open", null: false

      t.timestamps
    end
  end
end
