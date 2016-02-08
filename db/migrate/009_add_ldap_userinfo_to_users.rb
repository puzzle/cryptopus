# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class AddLdapUserinfoToUsers < ActiveRecord::Migration

  def up
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
        user.username  = get_ldap_info( user.uid.to_s, "uid" )
        user.givenname = get_ldap_info( user.uid.to_s, "givenname" )
        user.surname   = get_ldap_info( user.uid.to_s, "sn" )
      end
      user.save
    end
  end

  def down
    remove_column "users", "username"
    remove_column "users", "givenname"
    remove_column "users", "surname"
  end

private
  def get_ldap_info( uid, attribute )
    ldap_legacy_connect
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

  def ldap_legacy_connect
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
