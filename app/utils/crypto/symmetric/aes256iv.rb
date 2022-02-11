# frozen_string_literal: true

require 'openssl'
require 'digest/sha1'

require_relative './aes256'

class Crypto::Symmetric::AES256IV < Crypto::Symmetric::AES256

  class << self

    def encrypt(data, key)
      cipher = OpenSSL::Cipher.new(self.cipher)

      # set cipher mode to encrypt
      cipher.encrypt

      # set key for decryption as well as a random iv
      cipher.key = key
      iv = cipher.random_iv

      # encrypt given data
      encrypted_data = cipher.update(data) + cipher.final

      [encrypted_data, iv]
    end

    def decrypt(data, key, iv)
      cipher = OpenSSL::Cipher.new(self.cipher)

      # set cipher mode to decrypt
      cipher.decrypt

      cipher.key = key
      cipher.iv = iv

      # decrypt given data
      decrypted_data = cipher.update(data) + cipher.final
      decrypted_data.force_encoding('UTF-8')
    end
  end
end
