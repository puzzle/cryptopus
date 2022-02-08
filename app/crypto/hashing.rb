# frozen_string_literal: true

require 'digest/sha1'

class Hashing
  def self.hash(data)
    salt = SecureRandom.hex
    "sha512$#{salt}$" + Digest::SHA512.hexdigest(salt + data)
  end
end
