# frozen_string_literal: true

class PersonalLogsSerializer < ApplicationSerializer
  attributes :id, :event, :user_id, :username, :created_at,
             :encryptable_name, :folder_name, :team_name

  belongs_to :encryptable

  def user_id
    object.whodunnit
  end

  def encryptable
    object.item
  end
end
