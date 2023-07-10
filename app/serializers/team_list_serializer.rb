# frozen_string_literal: true

class TeamListSerializer < ApplicationSerializer
  # To hide STI name in Frontend
  type Team.name.pluralize
  attributes :id, :name, :type, :personal_team, :private, :unread_count

  has_many :folders, serializer: FolderMinimalSerializer

  def personal_team
    object.personal_team?
  end

  def unread_count
    object.is_a?(Team::Personal) ? object.unread_count_transferred_encryptables : nil
  end
end
