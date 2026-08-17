class DropTasks < ActiveRecord::Migration[8.1]
  def up
    drop_table :tasks
  end

  def down
    create_table :tasks do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
