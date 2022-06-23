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
  attributes :id, :name, :description, :private, :favourised, :deletable, :type,
             :encryption_algorithm, :password_bitsize

  has_many :folders, serializer: FolderSerializer

  def favourised
    object.personal_team? || current_user.favourite_team_ids.include?(object.id)
  end

  def deletable
    TeamPolicy.new(current_user, object).destroy?
  end

  def personal_team
    object.personal_team?
  end

  def password_bitsize
    object.encryption_class.password_bitsize
  end
end
