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
  include Authenticate

  validates :username, uniqueness: true
  validates :username, presence: true

  has_many :teammembers, dependent: :destroy
  has_many :recryptrequests, dependent: :destroy
  has_many :teams, -> {order :name}, through: :teammembers

  scope :locked, -> { where(locked: true)}
  scope :unlocked, -> { where(locked: false)}

  class << self
    # TODO create ldap user on first login

    def create_root(password)
      user = User.new(
        uid: 0,
        username: 'root',
        givenname: 'root',
        surname: '',
        auth: 'db',
        password: CryptUtils.one_way_crypt(password),
      )
      user.create_keypair(password)
      user.save
    end

    def create_from_ldap(username, password)
      # TODO simplify and refactor
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
  end

  #unlock user
  def unlock
    update_attribute(:locked, false)
  end
  # Updates Information about the user
  def update_info
    update_info_from_ldap if auth_ldap?
    update_attribute(:last_login_at, Time.now) # TODO needed what for ? remove ?
  end

  # Updates Information about the user from LDAP
  def update_info_from_ldap
    self.givenname = LdapTools.get_ldap_info( uid.to_s, "givenname" )
    self.surname   = LdapTools.get_ldap_info( uid.to_s, "sn" )
  end

  def create_keypair(password)
    keypair = CryptUtils.new_keypair
    uncrypted_private_key = CryptUtils.get_private_key_from_keypair(keypair)
    self.public_key = CryptUtils.get_public_key_from_keypair(keypair)
    self.private_key = CryptUtils.encrypt_private_key( uncrypted_private_key, password )
  end

  def full_name
    "#{givenname} #{surname}"
  end

  def root?
    uid == 0
  end

  def update_password(old, new)
    return if auth_ldap?
    if authenticate_db(old)
      self.password = CryptUtils.one_way_crypt(new)
      pk = CryptUtils.decrypt_private_key(self.private_key, old)
      self.private_key = CryptUtils.encrypt_private_key(pk, new)
      save
    end
  end

  def migrate_legacy_private_key(password)
    decrypted_legacy_private_key = CryptUtilsLegacy.decrypt_private_key( private_key, password )
    newly_encrypted_private_key = CryptUtils.encrypt_private_key( decrypted_legacy_private_key, password )
    update_attribute(:private_key, newly_encrypted_private_key)
  end

  def decrypt_private_key(password)
    begin
      migrate_legacy_private_key(password) if legacy_private_key?
      CryptUtils.decrypt_private_key(private_key, password)
    rescue
      raise Exceptions::DecryptFailed
    end
  end

  def legacy_private_key?
    /^Salted/ !~ private_key
  end
end
