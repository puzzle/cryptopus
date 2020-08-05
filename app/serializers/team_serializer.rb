# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id          :integer          not null, primary key
#  name        :string(40)       default(""), not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  visible     :boolean          default(TRUE), not null
#  private     :boolean          default(FALSE), not null
#

# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

class TeamSerializer < ApplicationSerializer
  attributes :id, :name, :description, :private, :favourised, :deletable

  has_many :folders, serializer: FolderMinimalSerializer

  def favourised
    users_favorised_current_team.include?(user.id)
  end

  def deletable
    TeamPolicy.new(user, object).destroy?
  end

  private

  def user
    current_user
  end

  def users_favorised_current_team
    @users_favorised_current_team ||= object.user_favourite_teams.pluck(:team_id)
  end
end
