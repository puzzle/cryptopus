# frozen_string_literal: true

class Encryptable::File < EncryptableSerializer
  attributes :cleartext_file, :created_at, :updated_at
end