class AddSettingsOrder < ActiveRecord::Migration
  def up
    add_column :settings, :order, :integer
    set_default_orders
  end

  def down
    remove_column :settings, :order
  end

  private
  
  def set_default_orders
    Setting.by_section('ldap').each_with_index do |s, i|
      s.update_attributes(order: i)
    end
  end

end
