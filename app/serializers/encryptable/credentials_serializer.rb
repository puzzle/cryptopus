# frozen_string_literal: true

class Encryptable::CredentialsSerializer < EncryptableSerializer
  attributes :cleartext_username, :cleartext_password, :cleartext_token, :cleartext_pin, :cleartext_email, :cleartext_custom_attr, :created_at, :updated_at

  def cleartext_custom_attr
    return nil unless object.encrypted_data[:custom_attr]
    {
      label: object.encrypted_data[:custom_attr]&.[](:label),
      value: object.cleartext_custom_attr
    }
  end

  has_many :encryptable_files
end
