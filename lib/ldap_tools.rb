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

  def LdapTools.ldap_login( username, password )
    return nil if Ldapsetting.exists?( :first ) == nil
    
    ldap_settings = Ldapsetting.find( :first )
    ldap = Net::LDAP.new \
      :host => ldap_settings.hostname,
      :port => ldap_settings.portnumber,
      :encryption => :simple_tls
      
    result = ldap.bind_as \
      :base => ldap_settings.basename,
      :filter => "uid=#{username}",
      :password => password
      
     if result
      user_dn = result.first.dn
      ldap = Net::LDAP.new \
        :host => ldap_settings.hostname,
        :port => ldap_settings.portnumber,
        :encryption => :simple_tls,
        :auth => { :method => :simple,
          :username => user_dn,
          :password => password
        }
        
      if ldap.bind
        return true
      end
    end
    return false
  end
  
  def LdapTools.get_uid_by_username( username )
    LdapTools.connect
    filter = Net::LDAP::Filter.eq( "uid", username )
    @@ldap.search( :base => @@ldap_settings.basename, :filter => filter, :attributes => ["uidnumber"] ) do | entry |
      entry.each do |attr, values|
        if attr.to_s == "uidnumber"
          return values[0].to_s
        end
      end
    end
    raise "UID of the user not found"
    return nil
  end
  
  def LdapTools.get_ldap_info( uid, attribute )
    LdapTools.connect
    filter = Net::LDAP::Filter.eq( "uidnumber", uid )
    @@ldap.search( :base => @@ldap_settings.basename, :filter => filter, :attributes => [attribute] ) do | entry |
      entry.each do |attr, values|
        if attr.to_s == attribute
          return values[0].to_s
        end
      end
    end
    return "No <#{attribute} for uid #{uid}>"
  end
  
  def LdapTools.connect
    if Ldapsetting.exists?( :first ) == nil
      return nil
    end
    
    @@ldap_settings = Ldapsetting.find( :first )
    @@ldap = Net::LDAP.new \
      :base => @@ldap_settings.basename,
      :host => @@ldap_settings.hostname,
      :port => @@ldap_settings.portnumber,
      :encryption => :simple_tls
    unless @@ldap_settings.bind_dn.nil? or @@ldap_settings.bind_dn == ""
      @@ldap.auth @@ldap_settings.bind_dn, @@ldapsettings.bind_password
    end
  end
  
end
