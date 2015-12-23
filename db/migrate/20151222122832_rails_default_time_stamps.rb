class RailsDefaultTimeStamps < ActiveRecord::Migration
  def change
    rename_column :teams, :created_on, :created_at
    rename_column :teams, :updated_on, :updated_at

    rename_column :groups, :created_on, :created_at
    rename_column :groups, :updated_on, :updated_at

    rename_column :accounts, :created_on, :created_at
    rename_column :accounts, :updated_on, :updated_at

    rename_column :items, :created_on, :created_at
    rename_column :items, :updated_on, :updated_at

    rename_column :teammembers, :created_on, :created_at
    rename_column :teammembers, :updated_on, :updated_at
  end
end
