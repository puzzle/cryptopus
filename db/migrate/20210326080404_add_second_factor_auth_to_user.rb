class AddSecondFactorAuthToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :second_factor_auth, :integer, default: 0, null: false
  end
end
