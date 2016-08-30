# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Teammember < ActiveRecord::Base
  delegate :label, to: :user
  belongs_to :team
  belongs_to :user
  before_destroy :protect_if_last_teammember
  before_destroy :protect_if_admin_in_non_private_team

  validates :user_id, uniqueness: { scope: :team }

  scope :list, -> { joins(:user).order('users.username') }
  scope :non_private_teams,  -> { joins(:team).where('teams.private' => false) }
  scope :private_teams,  -> { joins(:team).where('teams.private' => true) }

  
  def recrypt_team_password(user, admin, private_key)
    teammember_admin = admin.teammembers.find_by_team_id(self.team_id)
    team_password = CryptUtils.decrypt_team_password(teammember_admin.
      password, private_key)

    self.password = CryptUtils.encrypt_team_password(team_password, user.public_key)
    self.save
  end

  private

  def protect_if_last_teammember
    if team.teammembers.count == 1
      errors.add(:base, 'Cannot remove last teammember')
      false
    end
  end

  def protect_if_admin_in_non_private_team
    if !team.private? && user.admin?
      errors.add(:base, 'Admin user cannot be removed from non private team')
      false
    end
  end
end
