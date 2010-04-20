class BindCredentialsForLdap < ActiveRecord::Migration

  def self.up
    add_column "ldapsettings", "bind_dn",       :string, :default => nil
    add_column "ldapsettings", "bind_password", :string, :default => nil
  end

  def self.down
    remove_column "ldapsettings", "bind_dn"
    remove_column "ldapsettings", "bind_password"
  end

end
