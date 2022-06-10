# frozen_string_literal: true

require 'openssl'
require 'digest/sha1'

class ::Crypto::Symmetric
  class_attribute :password_bitsize

  LATEST_ALGORITHM = 'AES256'

  # Add further algorithms at the bottom
  ALGORITHMS = {
    AES256: ::Crypto::Symmetric::Aes256,
    AES256IV: ::Crypto::Symmetric::Aes256iv
  }.with_indifferent_access.freeze

  class << self

    def encrypt
      raise 'Implement in subclass'
    end

    def decrypt
      raise 'Implement in subclass'
    end

    def random_key
      raise 'Implement in subclass'
    end

    def all_algorithms
      ALGORITHMS.keys
    end

    def latest_algorithm?(entry)
      LATEST_ALGORITHM == entry.encryption_algorithm
    end
  end
end
