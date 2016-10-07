class RaiseAccountnameLimit < ActiveRecord::Migration
  def change
    change_column :accounts, :accountname, :string, limit: 70
  end
end
