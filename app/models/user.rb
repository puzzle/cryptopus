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

class User < ActiveRecord::Base
  has_many :teammembers, :dependent => :destroy
  has_many :recryptrequests, :dependent => :destroy
  has_many :teams, :through => :teammembers, :order => :name
  
  attr_accessible :username, :givenname, :surname, :password

  def self.authenticate( username, password )
    user = self.find_by_username username
    raise Exceptions::UserDoesNotExist if user.nil?
    authenticated = case user.auth
      when 'db'   then user.authenticate_against_db   password
      when 'ldap' then user.authenticate_against_ldap password
      else raise Exceptions::UnknownAuthenticationMethod
    end
    raise Exceptions::AuthenticationFailed unless authenticated
  end

  def self.create_root( password )
    user = self.new
    user.uid = 0
    user.username = 'root'
    user.givenname = 'root'
    user.surname = ''
    user.auth = 'db'
    user.password = CryptUtils.one_way_crypt( password )
    user.create_keypair password
    user.update_info
  end

  def self.create_from_external_auth( username, password )
    # @@@ TODO check for external auth methods
    # At the moment we just support LDAP
    User.create_from_ldap( username, password )
  end

  def self.create_from_ldap( username, password )
    raise Exceptions::AuthenticationFailed unless LdapTools.ldap_login(username, password)
    begin
      user = self.new
      user.username = username
      user.auth = 'ldap'
      user.uid = LdapTools.get_uid_by_username( username )
      user.create_keypair password
      user.update_info
    rescue
      raise Exceptions::UserCreationFailed
    end
  end

  # Updates Information about the user
  def update_info
    self.update_info_from_ldap if self.auth == 'ldap'
    self.last_login_at = Time.now
    self.save
  end

  # Updates Information about the user from LDAP
  def update_info_from_ldap
    self.givenname = LdapTools.get_ldap_info( uid.to_s, "givenname" )
    self.surname   = LdapTools.get_ldap_info( uid.to_s, "sn" )
  end

  def authenticate_against_db( par_password )
    crypted_password = CryptUtils.one_way_crypt( par_password )
    return self.password == crypted_password
  end

  def authenticate_against_ldap( par_password )
    return LdapTools.ldap_login(username, par_password)
  end

  def create_keypair( par_password )
    keypair = CryptUtils.new_keypair
    uncrypted_private_key = CryptUtils.get_private_key_from_keypair( keypair )
    self.public_key = CryptUtils.get_public_key_from_keypair( keypair )
    self.private_key = CryptUtils.encrypt_private_key( uncrypted_private_key, par_password )
    self.save
  end

  def full_name
    return self.givenname + ' ' + self.surname
  end
  
  def root?
    self.uid == 0
  end

end
