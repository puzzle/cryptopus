# frozen_string_literal: true

class EncryptableMinimalSerializer < ApplicationSerializer
  attributes :id, :name, :description, :created_at, :sender_name, :used_attrs

  def sender_name
    object.sender&.label
  end

  def used_attrs
    keys = [:password, :username, :token, :pin, :email, :custom_attr]
    data = object.encrypted_data.instance_variable_get(:@data)

    keys.index_with do |key|
      !data[key].nil?
    end
  end
end
