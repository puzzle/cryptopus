# frozen_string_literal: true

class PersonalLogsSerializer < ApplicationSerializer
  attributes :id, :event, :user_id, :username, :created_at, :folder_name, :team_name

  belongs_to :encryptable, serializer: EncryptableMinimalSerializer

  def user_id
    object.whodunnit
  end

  def username
    object.user.username
  end

  def folder_name
    object.encryptable.folder.name
  end

  def team_name
    object.encryptable.folder.team.name
  end
end
