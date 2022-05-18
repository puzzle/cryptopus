# frozen_string_literal: true

class PersonalLogsSerializer < ApplicationSerializer
  attributes :id, :event, :user_id, :username, :created_at,
             :encryptable_name, :folder_name, :team_name

  belongs_to :encryptable

  def user_id
    object.whodunnit
  end

  def encryptable
    object.encryptable
  end

  def username
    object.user.username
  end

  def encryptable_name
    object.encryptable.name
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
