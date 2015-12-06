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

class Team < ActiveRecord::Base
  has_many :groups, -> {order :name}, dependent: :destroy
  has_many :teammembers, dependent: :delete_all

  def teammember_candidates
    excluded_user_ids = User.joins('LEFT JOIN teammembers ON users.id = teammembers.user_id').
                          where('users.uid = 0 OR users.admin = ? OR teammembers.team_id = ?', true, id).
                          distinct.
                          pluck(:id)
    User.where('id NOT IN(?)', excluded_user_ids)
  end

  def last_teammember?(user_id)
    teammembers.count == 1 && teammember?(user_id)
  end

  def teammember?(user_id)
    teammember(user_id).present?
  end

  def teammember(user_id)
    teammembers.where(user_id: user_id).first
  end

  def add_user(user, plaintext_team_password = nil)
    return add_first_user(user) unless teammembers.present?
    raise 'user is already team member' if teammember?(user.id)
    create_teammember(user, plaintext_team_password)
  end

  def remove_user(user)
    raise 'user is not a team member' unless teammember?(user.id)
    teammember(user.id).destroy!
  end

  def decrypt_team_password(user, plaintext_private_key)
    crypted_team_password = teammember(user.id).password
    CryptUtils.
      decrypt_team_password(crypted_team_password, plaintext_private_key)
  end

  private
  def add_first_user(user)
    plaintext_team_password = CryptUtils.new_team_password
    create_teammember(user, plaintext_team_password)
  end

  def create_teammember(user, plaintext_team_password)
    crypted_team_password = CryptUtils.
      encrypt_team_password(plaintext_team_password, user.public_key)

    teammembers.create!(password: crypted_team_password, 
                       user: user, 
                       admin: user.admin?) 
  end

end
