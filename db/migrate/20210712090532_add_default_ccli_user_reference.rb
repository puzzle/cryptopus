class AddDefaultCcliUserReference < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :default_ccli_user, index: true
  end
end
