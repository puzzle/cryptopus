# frozen_string_literal: true

require 'openssl'
require 'digest/sha1'

class Symmetric::AES256 < Symmetric
  @@CYPHER = 'aes-256-cbc'
  @@MAGIC = 'Salted__'

  @@SALT_LENGTH = 8
  @@ITERATIONS = 1000

  class << self

    def encrypt(data, key)
      cipher = OpenSSL::Cipher.new(@@CYPHER)
      cipher.encrypt
      cipher.key = key
      crypted_data = cipher.update(data)
      crypted_data << cipher.final
      crypted_data
    end

    def decrypt(data, key)
      cipher = OpenSSL::Cipher.new(@@CYPHER)
      cipher.decrypt
      cipher.key = key
      decrypted_data = cipher.update(data)
      decrypted_data << cipher.final
      decrypted_data.force_encoding('UTF-8')
    end

    def encrypt_with_salt(key, data)
      cipher = OpenSSL::Cipher.new(@@CYPHER)
      cipher.encrypt
      salt = OpenSSL::Random.random_bytes(@@SALT_LENGTH)
      cipher.pkcs5_keyivgen(data, salt, @@ITERATIONS)
      private_key_part = cipher.update(key) + cipher.final

      @@MAGIC + salt + private_key_part
    end

    def decrypt_with_salt(key, data)
      cipher = OpenSSL::Cipher.new(@@CYPHER)
      cipher.decrypt

      raise 'magic does not match' unless key.slice(0, @@MAGIC.size) == @@MAGIC

      salt = key.slice(@@MAGIC.size, @@SALT_LENGTH)
      private_key_part = key.slice((@@MAGIC.size + @@SALT_LENGTH)..-1)
      cipher.pkcs5_keyivgen(data, salt, 1000)
      cipher.update(private_key_part) + cipher.final
    rescue StandardError
      raise Exceptions::DecryptFailed
    end

    def random_key
      cipher = OpenSSL::Cipher.new(@@cypher)
      cipher.random_key
    end

  end

end

