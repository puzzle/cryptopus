# frozen_string_literal: true

class TeamListSerializer < ApplicationSerializer
  # To hide STI name in Frontend
  type Team.name.pluralize
  attributes :id, :name, :type, :personal_team, :private, :unread_transferred_files

  has_many :folders, serializer: FolderMinimalSerializer

  def personal_team
    object.personal_team?
  end

  def unread_transferred_files
      # rubocop:enable Metrics/LineLength
      object.personal_team? ? Folder.find(object.folders.where(name: "inbox").first.id).encryptables.all.where.not(encrypted_transfer_password: nil).count : 0
      # rubocop:disable Metrics/LineLength
  end
end
