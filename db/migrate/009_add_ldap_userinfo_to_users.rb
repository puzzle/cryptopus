class AddLdapUserinfoToUsers < ActiveRecord::Migration

  def self.up
    add_column "users", "username", :string
    add_column "users", "givenname", :string
    add_column "users", "surname", :string

    User.reset_column_information
    User.all.each do |user|
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

  def LdapTools.get_ldap_info( uid, attribute )
    LdapTools.connect
    filter = Net::LDAP::Filter.eq( "uidnumber", uid )
    @@ldap.search( base: @@ldap_settings.basename, filter: filter, attributes: [attribute] ) do | entry |
      entry.each do |attr, values|
        if attr.to_s == attribute
          return values[0].to_s
        end
      end
    end
    return "No <#{attribute} for uid #{uid}>"
  end

  def LdapTools.connect
    if Ldapsetting.first.blank?
      return nil
    end

    @@ldap_settings = Ldapsetting.first
    @@ldap = Net::LDAP.new \
      base: @@ldap_settings.basename,
      host: @@ldap_settings.hostname,
      port: @@ldap_settings.portnumber,
      encryption: :simple_tls
  end

  class Ldapsetting < ActiveRecord::Base
  end
end
