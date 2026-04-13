class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :agent, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "pending"
      t.text :result
      t.string :branch_name
      t.string :working_directory, null: false
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :tasks, :status
  end
end
