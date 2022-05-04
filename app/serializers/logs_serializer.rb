# frozen_string_literal: true

class LogsSerializer < ApplicationSerializer
  attributes :id, :item_type, :event, :user_id, :username, :created_at

  belongs_to :encryptable

  def user_id
    object.whodunnit
  end

  def username
    User.find(object.whodunnit).username
  end

  def encryptable
    object.item
  end
end
