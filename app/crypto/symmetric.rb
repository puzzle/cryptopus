# frozen_string_literal: true

require 'openssl'
require 'digest/sha1'

class Symmetric
  @@cypher = ""

  class << self
    def encrypt(data, key)
      raise 'Implement in subclass'
    end

    def decrypt(data, key)
      raise 'Implement in subclass'
    end

    def random_key
      raise 'Implement in subclass'
    end
  end

end
