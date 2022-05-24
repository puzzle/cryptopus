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

class TeamSerializer < ApplicationSerializer
  # To hide STI name in Frontend
  type Team.name.pluralize
  attributes :id, :name, :description, :private, :favourised, :deletable, :type

  has_many :folders, serializer: FolderMinimalSerializer

  def favourised
    object.personal_team? || user_favourite_team_ids.include?(object.id)
  end

  def deletable
    TeamPolicy.new(user, object).destroy?
  end

  def personal_team
    object.personal_team?
  end

  private

  def user
    current_user
  end

  def user_favourite_team_ids
    @user_favourite_team_ids ||= user.user_favourite_teams.pluck(:team_id)
  end
end
