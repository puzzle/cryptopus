# frozen_string_literal: true

require 'openssl'
require 'digest/sha1'

class ::Crypto::Symmetric
  class_attribute :password_bitsize

  # Add further algorithms at the bottom
  ALGORITHMS = {
    AES256: ::Crypto::Symmetric::Aes256,
    AES256IV: ::Crypto::Symmetric::Aes256iv
  }.freeze
               .with_indifferent_access

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

    def latest_algorithm
      'AES256'
    end

    def all
      ALGORITHMS.keys
    end

    def latest_algorithm?(entry)
      latest_algorithm == entry.encryption_algorithm
    end
  end
end
