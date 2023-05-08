# frozen_string_literal: true

class EncryptableMinimalSerializer < ApplicationSerializer
  attributes :id, :name, :description, :created_at, :sender_name, :used_attrs

  def sender_name
    object.sender&.label
  end

  def used_attrs
    used_attrs = {}
    data = object.encrypted_data.instance_variable_get(:@data)
    used_attrs[:password] = !data[:password].nil?
    used_attrs[:username] = !data[:username].nil?
    used_attrs[:token] = !data[:token].nil?
    used_attrs[:pin] = !data[:pin].nil?
    used_attrs[:email] = !data[:email].nil?
    used_attrs[:custom_attr] = !data[:custom_attr].nil?
    used_attrs
  end
end
