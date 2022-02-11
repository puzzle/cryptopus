# frozen_string_literal: true

require 'openssl'
require 'digest/sha1'

class Crypto::Symmetric::AES256 < Crypto::Symmetric
  class_attribute :cypher
  class_attribute :magic
  class_attribute :salt_length
  class_attribute :iteration_count

  self.cypher = 'aes-256-cbc'
  self.magic = 'Salted__'
  self.salt_length = 8
  self.iteration_count = 1000

  class << self

    def encrypt(data, key)
      cipher = OpenSSL::Cipher.new(self.cypher)
      cipher.encrypt
      cipher.key = key
      crypted_data = cipher.update(data)
      crypted_data << cipher.final
      crypted_data
    end

    def decrypt(data, key)
      cipher = OpenSSL::Cipher.new(self.cypher)
      cipher.decrypt
      cipher.key = key
      decrypted_data = cipher.update(data)
      decrypted_data << cipher.final
      decrypted_data.force_encoding('UTF-8')
    end

    def encrypt_with_salt(key, data)
      cipher = OpenSSL::Cipher.new(self.cypher)
      cipher.encrypt
      salt = OpenSSL::Random.random_bytes(self.salt_length)
      cipher.pkcs5_keyivgen(data, salt, self.iteration_count)
      private_key_part = cipher.update(key) + cipher.final

      self.magic + salt + private_key_part
    end

    def decrypt_with_salt(key, data)
      cipher = OpenSSL::Cipher.new(self.cypher)
      cipher.decrypt

      raise 'magic does not match' unless key.slice(0, self.magic.size) == self.magic

      salt = key.slice(self.magic.size, self.salt_length)
      private_key_part = key.slice((self.magic.size + self.salt_length)..-1)
      cipher.pkcs5_keyivgen(data, salt, 1000)
      cipher.update(private_key_part) + cipher.final
    rescue StandardError
      raise Exceptions::DecryptFailed
    end

    def random_key
      cipher = OpenSSL::Cipher.new(self.cypher)
      cipher.random_key
    end
  end
end

