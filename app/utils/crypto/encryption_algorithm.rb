# frozen_string_literal: true

class Crypto::EncryptionAlgorithm

  # Add further algorithms at the bottom
  SYMMETRIC_ENCRYPTION_ALGORITHMS = [
    :AES256,
    :AES256IV
  ].freeze

  class << self
    def latest
      SYMMETRIC_ENCRYPTION_ALGORITHMS.last
    end

    def get_class(name)
      class_name = name.capitalize.to_sym
      ::Crypto::Symmetric.const_get(class_name)
    end

    def latest_in_use?(entry)
      latest == entry.encryption_algorithm
    end
  end
end