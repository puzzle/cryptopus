# frozen_string_literal: true

class Crypto::EncryptionAlgorithm

  # Add further algorithms at the bottom
  SYMMETRIC_ENCRYPTION_ALGORITHMS = {
    AES256: Crypto::Symmetric::Aes256,
    AES256IV: Crypto::Symmetric::Aes256iv
  }

  class << self
    def latest_algorithm
      :AES256IV
    end

    def get_class(name)
      SYMMETRIC_ENCRYPTION_ALGORITHMS[name.to_sym]
    end

    def all
      SYMMETRIC_ENCRYPTION_ALGORITHMS.keys
    end

    def latest_in_use?(entry)
      latest_algorithm == entry.encryption_algorithm
    end
  end
end