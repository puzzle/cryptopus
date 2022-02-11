# frozen_string_literal: true

require 'openssl'
require 'digest/sha1'

class Crypto::Symmetric::AES256 < Crypto::Symmetric
  class_attribute :cipher
  class_attribute :magic
  class_attribute :salt_length
  class_attribute :iteration_count

  self.cipher = 'AES-256-CBC'
  self.magic = 'Salted__'
  self.salt_length = 8
  self.iteration_count = 1000

  class << self

    def encrypt(data, key)
      cipher = cipher_encrypt_mode

      # set encryption key
      cipher.key = key

      # return encrypted data
      cipher.update(data) + cipher.final
    end

    def decrypt(data, key)
      cipher = cipher_decrypt_mode

      # set decryption key
      cipher.key = key

      # decrypt data
      decrypted_data = cipher.update(data) + cipher.final
      decrypted_data.force_encoding('UTF-8')
    end

    def encrypt_with_salt(data, key)
      cipher = cipher_encrypt_mode
      salt = generate_salt

      # generates and sets key/iv
      cipher.pkcs5_keyivgen(key, salt, self.iteration_count)

      # encrypt data
      encrypted_private_key = cipher.update(data) + cipher.final

      self.magic + salt + encrypted_private_key
    end

    def decrypt_with_salt(data, key)
      cipher = cipher_decrypt_mode
      raise 'magic does not match' unless extract_magic_from(data) == self.magic

      salt = extract_salt_from(data)
      encrypted_data = extract(data)

      # generates and sets key/iv
      cipher.pkcs5_keyivgen(key, salt, self.iteration_count)

      # decrypt data
      cipher.update(encrypted_data) + cipher.final
    rescue StandardError
      raise Exceptions::DecryptFailed
    end

    def random_key
      cipher_encrypt_mode.random_key
    end

    private

    def cipher_encrypt_mode
      cipher = OpenSSL::Cipher.new(self.cipher)
      cipher.encrypt
      cipher
    end

    def cipher_decrypt_mode
      cipher = OpenSSL::Cipher.new(self.cipher)
      cipher.decrypt
      cipher
    end

    def generate_salt
      OpenSSL::Random.random_bytes(self.salt_length)
    end

    def extract_magic_from(data)
      data.slice(0, self.magic.size)
    end

    def extract_salt_from(data)
      data.slice(self.magic.size, self.salt_length)
    end

    def extract(data)
      data.slice((self.magic.size + self.salt_length)..-1)
    end
  end
end

