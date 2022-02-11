# frozen_string_literal: true

require 'digest/sha1'

class Crypto::Hashing

  class << self
    def generate_salted(password)
      salt = SecureRandom.hex
      "sha512$#{salt}$" + hexdigest(salt, password)
    end

    def matches?(salted_hash, password)
      salt = salted_hash.split('$')[1]
      salted_hash.split('$')[2] == hexdigest(salt, password)
    end

    private

    def hexdigest(salt, password)
      Digest::SHA512.hexdigest(salt + password)
    end
  end
end
