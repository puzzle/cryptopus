# frozen_string_literal: true

class TeamListSerializer < ApplicationSerializer
  # To hide STI name in Frontend
  type Team.name.pluralize
  attributes :id, :name, :type, :personal_team, :private

  has_many :folders, serializer: FolderMinimalSerializer

  def personal_team
    object.personal_team?
  end
end
