class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.string :output
      t.string :status
      t.string :log_type
      t.integer :executer_id
      t.timestamps null: false
    end
  end
end
