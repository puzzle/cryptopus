# frozen_string_literal: true

class EncryptableMinimalSerializer < ApplicationSerializer
  attributes :id, :name, :description, :created_at, :sender_name, :used_encrypted_data_attrs

  def sender_name
    object.sender&.label
  end

  def used_encrypted_data_attrs
    object.encrypted_data.used_encrypted_data_attrs
  end
end
