# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'openssl'
require 'digest/sha1'

class CryptUtils

  @@magic = 'Salted__'
  @@salt_length = 8
  @@cypher = 'aes-256-cbc'

  class << self
    include OpenSSL

    def encrypt_rsa(content, public_key)
      keypair = PKey::RSA.new(public_key)
      encrypted_content = keypair.public_encrypt(content)
      encrypted_content
    rescue StandardError
      nil
    end

    def new_team_password
      cipher = OpenSSL::Cipher.new(@@cypher)
      cipher.random_key
    end

    def encrypt_private_key(private_key, password)
      cipher = OpenSSL::Cipher.new(@@cypher)
      cipher.encrypt
      salt = OpenSSL::Random.random_bytes(@@salt_length)
      cipher.pkcs5_keyivgen password, salt, 1000
      private_key_part = cipher.update(private_key) + cipher.final

      @@magic + salt + private_key_part
    end

    def decrypt_private_key(private_key, password)
      cipher = OpenSSL::Cipher.new(@@cypher)
      cipher.decrypt

      raise 'magic does not match' unless private_key.slice(0, @@magic.size) == @@magic

      salt = private_key.slice(@@magic.size, @@salt_length)
      private_key_part = private_key.slice((@@magic.size + @@salt_length)..-1)
      cipher.pkcs5_keyivgen(password, salt, 1000)
      cipher.update(private_key_part) + cipher.final
    rescue StandardError
      raise Exceptions::DecryptFailed
    end

    def encrypt_blob(blob, team_password)
      cipher = OpenSSL::Cipher.new(@@cypher)
      cipher.encrypt
      cipher.key = team_password
      crypted_blob = cipher.update(blob)
      crypted_blob << cipher.final
      crypted_blob
    end

    def decrypt_blob(blob, team_password)
      cipher = OpenSSL::Cipher.new(@@cypher)
      cipher.decrypt
      cipher.key = team_password
      decrypted_blob = cipher.update(blob)
      decrypted_blob << cipher.final
      decrypted_blob.force_encoding('UTF-8')
    end

    def encrypt_base64(data, encryption_key)
      cipher = OpenSSL::Cipher.new(@@cypher)
      cipher.encrypt
      cipher.key = encryption_key
      iv = random_iv
      cipher.iv = iv
      encrypted_data = cipher.update(data)
      encrypted_data << cipher.final
      [Base64.strict_encode64(encrypted_data), iv]
    end

    def decrypt_base64(data, encryption_key, iv)
      cipher = OpenSSL::Cipher.new(@@cypher)
      cipher.decrypt
      cipher.key = encryption_key
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
