# frozen_string_literal: true

class LogsSerializer < ApplicationSerializer
  attributes :id, :item_type, :event, :whodunnit, :object, :created_at

  belongs_to :encryptable

  def encryptable
    object.item
  end
end
