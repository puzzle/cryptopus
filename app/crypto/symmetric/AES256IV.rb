# frozen_string_literal: true

require 'openssl'
require 'digest/sha1'

class Symmetric::AES256IV < AES256
   class << self
    def encrypt(data, key)
      cipher = OpenSSL::Cipher.new(@@cypher)
      cipher.encrypt
      cipher.key = key
      iv = random_iv
      cipher.iv = iv
      encrypted_data = cipher.update(data)
      encrypted_data << cipher.final
      [Base64.strict_encode64(encrypted_data), iv]
    end

    def decrypt(data, key, iv)
      cipher = OpenSSL::Cipher.new(@@cypher)
      cipher.decrypt
      cipher.key = key
      cipher.iv = iv
      decrypted_data = cipher.update(Base64.strict_decode64(data))
      decrypted_data << cipher.final
      decrypted_data.force_encoding('UTF-8')
    end

    def random_iv
      cipher = OpenSSL::Cipher.new(@@cypher)
      cipher.random_iv
    end

  end
end

