class AddCategoryToAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :category, :integer, default: 0, null: false
  end
end
