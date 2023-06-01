# frozen_string_literal: true

class Encryptable::CredentialsSerializer < EncryptableSerializer
  attributes :cleartext_username, :cleartext_password, :cleartext_token, :cleartext_pin,
             :cleartext_email , :cleartext_custom_attr_label, :cleartext_custom_attr, :created_at, :updated_at


  has_many :encryptable_files
end
