class RemoveMaintenanceTaskEntries < ActiveRecord::Migration[6.1]
  def change
    drop_table :maintenance_task do |t|
      t.string label
      t.string description
      t.string hint
      t.string task_params
      t.string error
      t.string id
    end
  end
end
