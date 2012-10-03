class AddLdapUserinfoToUsers < ActiveRecord::Migration

  def self.up
    add_column "users", "username", :string
    add_column "users", "givenname", :string
    add_column "users", "surname", :string

    User.reset_column_information
    User.find(:all).each do |user|
      if user.uid == 0
        user.username  = 'root'
        user.givenname = 'root'
        user.surname   = ''
      else
        user.username  = LdapTools.get_ldap_info( user.uid.to_s, "uid" )
        user.givenname = LdapTools.get_ldap_info( user.uid.to_s, "givenname" )
        user.surname   = LdapTools.get_ldap_info( user.uid.to_s, "sn" )
      end
      user.save
    end
  end

  def self.down
    remove_column "users", "username"
    remove_column "users", "givenname"
    remove_column "users", "surname"
  end

end
