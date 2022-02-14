# frozen_string_literal: true

require 'openssl'
require 'digest/sha1'

class Crypto::Symmetric

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
  end
end
