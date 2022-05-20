# frozen_string_literal: true

class Crypto::EncryptionAlgorithm

  # Add further algorithms at the bottom
  ENCRYPTION_ALGORITHMS = [
    :AES256,
    :AES256IV
  ].freeze

  class << self
    def default
      ENCRYPTION_ALGORITHMS.last
    end

    def retrieve_class_from_string(name)
      ::Crypto::Symmetric.const_get(name)
    end
  end
end