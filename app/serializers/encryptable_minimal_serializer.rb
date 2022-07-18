# frozen_string_literal: true

class EncryptableMinimalSerializer < ApplicationSerializer
  attributes :id, :name, :description, :sender_name

  def sender_name
    object.sender&.label
  end
end
