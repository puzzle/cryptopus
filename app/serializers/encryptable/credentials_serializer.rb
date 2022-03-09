# frozen_string_literal: true

class Encryptable::CredentialsSerializer < EncryptableSerializer
  attributes :cleartext_username, :cleartext_password, :created_at, :updated_at
end
