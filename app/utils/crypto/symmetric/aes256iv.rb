# frozen_string_literal: true

require 'openssl'
require 'digest/sha1'

require_relative './aes256'

class Crypto::Symmetric::Aes256iv < Crypto::Symmetric::Aes256

  class << self

    def encrypt(data, key)
      cipher = cipher_encrypt_mode

      # set key for decryption as well as a random iv
      cipher.key = key
      iv = cipher.random_iv

      # encrypt given data
      encrypted_data = cipher.update(data) + cipher.final

      { data: encrypted_data, iv: iv }
    end

    def decrypt(encrypted_data, key)
      cipher = cipher_decrypt_mode

      cipher.key = key
      cipher.iv = encrypted_data[:iv]

      # decrypt given data
      decrypted_data = cipher.update(encrypted_data[:data]) + cipher.final
      decrypted_data.force_encoding('UTF-8')
    end
  end
end
