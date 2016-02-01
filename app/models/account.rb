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

class Account < ActiveRecord::Base

  belongs_to :group
  has_many :items, :dependent => :destroy

  attr_accessor :cleartext_password, :cleartext_username

  def as_json(options = { })
    h =super(options)
    h[:group] = group.name
    h[:team] = group.team.name
    h[:team_id] = group.team.id
    h[:cleartext_password] = cleartext_password
    h[:cleartext_username] = cleartext_username
    h.delete('description')
    h.delete('created_at')
    h.delete('updated_at')
    h.delete('username')
    h.delete('password')
    h
  end

  def label
    accountname
  end
  
  def decrypt(team_password)
    @cleartext_username = decrypt_attr(:username, team_password)
    @cleartext_password = decrypt_attr(:password, team_password)
  end

  def encrypt(team_password)
    encrypt_username(team_password)
    encrypt_password(team_password)
  end

  private
  def decrypt_attr(attr, team_password)
    crypted_value = send(attr)
    return unless crypted_value.present?
    CryptUtils.decrypt_blob(crypted_value, team_password)
  end

  def encrypt_username(team_password)
    return unless cleartext_username.present?
    crypted_value = CryptUtils.encrypt_blob(cleartext_username, team_password)
    self.username = crypted_value
  end

  def encrypt_password(team_password)
    return unless cleartext_password.present?
    crypted_value = CryptUtils.encrypt_blob(cleartext_password, team_password)
    self.password = crypted_value
  end

end
