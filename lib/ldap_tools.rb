# $Id$

# Copyright (c) 2007 Puzzle ITC GmbH. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'net/ldap'

class LdapTools
 class << self
  def ldap_login( username, password )
    return nil unless Setting.value(:ldap, :enable)

#TODO
    ldap = Net::LDAP.new \
      host: Setting.value(:ldap, :hostname),
      port: Setting.value(:ldap, :portnumber),
      encryption: :simple_tls

    result = ldap.bind_as \
      base: Setting.value(:ldap, :basename),
      filter: "uid=#{username}",
      password: password

     if result
      user_dn = result.first.dn
      ldap = Net::LDAP.new \
      host: Setting.value(:ldap, :hostname),
      port: Setting.value(:ldap, :portnumber),
      encryption: :simple_tls,
      auth: { method: :simple,
          username: user_dn,
          password: password
        }

      if ldap.bind
        return true
      end
    end
    return false
  end

  def get_uid_by_username( username )
    LdapTools.connect
    filter = Net::LDAP::Filter.eq( "uid", username )
    @@ldap.search( base: Setting.value(:ldap, :basename), filter: filter, attributes: ["uidnumber"] ) do | entry |
      entry.each do |attr, values|
        if attr.to_s == "uidnumber"
          return values[0].to_s
        end
      end
    end
    raise "UID of the user not found"
    return nil
  end

  def get_ldap_info( uid, attribute )
    LdapTools.connect
    filter = Net::LDAP::Filter.eq( "uidnumber", uid )
    @@ldap.search( base: Setting.value(:ldap, :basename), filter: filter, attributes: [attribute] ) do | entry |
      entry.each do |attr, values|
        if attr.to_s == attribute
          return values[0].to_s
        end
      end
    end
    return "No <#{attribute} for uid #{uid}>"
  end

  def connect
    unless Setting.value(:ldap, :enable).value
      return nil
    end

    @@ldap = Net::LDAP.new \
      base: Setting.value(:ldap, :basename),
      host: Setting.value(:ldap, :hostname),
      port: Setting.value(:ldap, :portnumber),
      encryption: :simple_tls
    unless Setting.value(:ldap, :bind_dn).empty?
      @@ldap.auth Setting.value(:ldap, :bind_dn), Setting.value(:ldap, :bind_password)
    end
  end
 end
end
