# frozen_string_literal: true

class Encryptable::FileSerializer < ApplicationSerializer
  attributes :id, :name, :description, :sender_name

  def sender_name
    object.sender&.label
  end

  belongs_to :encryptable_credential
end
