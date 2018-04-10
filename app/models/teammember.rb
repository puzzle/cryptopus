# encoding: utf-8

# == Schema Information
#
# Table name: teammembers
#
#  id         :integer          not null, primary key
#  team_id    :integer          default(0), not null
#  password   :binary           not null
#  user_id    :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Teammember < ApplicationRecord
  delegate :label, to: :user
  belongs_to :team
  belongs_to :user, class_name: 'User', foreign_key: :user_id
  before_destroy :protect_if_last_teammember
  before_destroy :protect_if_admin_in_non_private_team
  before_destroy :remove_api_users
  # TODO: -> on destroy: remove api-token user first if present

  validates :user_id, uniqueness: { scope: :team }

  scope :list, (-> { joins(:user).order('users.username') })
  scope :in_non_private_teams, (-> { joins(:team).where('teams.private' => false) })
  scope :in_private_teams, (-> { joins(:team).where('teams.private' => true) })


  def recrypt_team_password(user, admin, private_key)
    teammember_admin = admin.teammembers.find_by(team_id: team_id)
    team_password = CryptUtils.decrypt_rsa(teammember_admin.
      password, private_key)

    self.password = CryptUtils.encrypt_rsa(team_password, user.public_key)
    save
  end

  private

  def protect_if_last_teammember
    if team.teammembers.count == 1
      errors.add(:base, 'Cannot remove last teammember')
      throw :abort
    end
  end

  def protect_if_admin_in_non_private_team
    if !team.private? && user.admin?
      errors.add(:base, 'Admin user cannot be removed from non private team')
      throw :abort
    end
  end

  def remove_api_users
    return unless user.is_a?(User::Human)
    ids = user.api_users.pluck(:id)
    team.teammembers.where(user_id: ids).destroy_all
  end

  def create_team_api_user(api_user)
    Team::ApiUser.new(api_user, team)
  end
end
