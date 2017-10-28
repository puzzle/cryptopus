# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'openssl'
require 'digest/sha1'

include OpenSSL

class CryptUtils
  @@magic = 'Salted__'
  @@salt_length = 8
  @@cypher = 'aes-256-cbc'

  class << self
    def one_way_crypt(plaintext_password)
      salt = SecureRandom.hex
      "sha512$#{salt}$" + Digest::SHA512.hexdigest(salt + plaintext_password)
    end

    def legacy_one_way_crypt(password)
      Digest::SHA1.hexdigest(password)
    end

    def new_keypair
      keypair = PKey::RSA.new(2048)
      keypair
    end

    def extract_private_key(keypair)
      keypair.to_s
    end

    def extract_public_key(keypair)
      keypair.public_key.to_s
    end

    def decrypt_rsa(encrypted_content, private_key)
      keypair = PKey::RSA.new(private_key)
      decrypted_content = keypair.private_decrypt(encrypted_content)
      return decrypted_content
    rescue
      return nil
    end

    def encrypt_rsa(content, public_key)
      keypair = PKey::RSA.new(public_key)
      encrypted_content = keypair.public_encrypt(content)
      return encrypted_content
    rescue
      return nil
    end

    def new_team_password
      cipher = OpenSSL::Cipher::Cipher.new(@@cypher)
      cipher.random_key
    end

    def encrypt_private_key(private_key, password)
      cipher = OpenSSL::Cipher::Cipher.new(@@cypher)
      cipher.encrypt
      salt = OpenSSL::Random.pseudo_bytes @@salt_length
      cipher.pkcs5_keyivgen password, salt, 1000
      private_key_part = cipher.update(private_key) + cipher.final

      @@magic + salt + private_key_part
    end

    def decrypt_private_key(private_key, password)
      cipher = OpenSSL::Cipher::Cipher.new(@@cypher)
      cipher.decrypt

      raise 'magic does not match' unless private_key.slice(0, @@magic.size) == @@magic

      salt = private_key.slice(@@magic.size, @@salt_length)
      private_key_part = private_key.slice((@@magic.size + @@salt_length)..-1)
      cipher.pkcs5_keyivgen(password, salt, 1000)
      return cipher.update(private_key_part) + cipher.final
    rescue
      raise Exceptions::DecryptFailed
    end

    def validate_keypair(private_key, public_key)
      test_data = 'Test Data'
      encrypted_test_data = CryptUtils.encrypt_team_password(test_data, public_key)
      unless test_data == CryptUtils.decrypt_team_password(encrypted_test_data, private_key)
        raise Exceptions::DecryptFailed
      end
    end

    def encrypt_blob(blob, team_password)
      cipher = OpenSSL::Cipher::Cipher.new(@@cypher)
      cipher.encrypt
      cipher.key = team_password
      crypted_blob = cipher.update(blob)
      crypted_blob << cipher.final
      crypted_blob
    end

    def decrypt_blob(blob, team_password)
      cipher = OpenSSL::Cipher::Cipher.new(@@cypher)
      cipher.decrypt
      cipher.key = team_password
      decrypted_blob = cipher.update(blob)
      decrypted_blob << cipher.final
      decrypted_blob.force_encoding('UTF-8')
    end
  end

end
