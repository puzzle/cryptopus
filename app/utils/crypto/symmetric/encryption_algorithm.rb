# frozen_string_literal: true

class Crypto::Symmetric::EncryptionAlgorithm

  # Add further algorithms at the bottom
  ALGORITHMS = {
    AES256: Crypto::Symmetric::Aes256,
    AES256IV: Crypto::Symmetric::Aes256iv
  }

  class << self
    def latest_algorithm
      :AES256IV
    end

    def all
      ALGORITHMS.keys
    end

    def latest_in_use?(entry)
      latest_algorithm == entry.encryption_algorithm
    end
  end
end