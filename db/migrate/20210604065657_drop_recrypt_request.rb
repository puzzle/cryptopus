class DropRecryptRequest < ActiveRecord::Migration[6.1]
  def change
    drop_table :recryptrequests
  end
end
