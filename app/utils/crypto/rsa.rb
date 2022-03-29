# frozen_string_literal: true

require 'openssl'

class Crypto::Rsa

  class << self

    def encrypt(data, public_key)
      keypair = OpenSSL::PKey::RSA.new(public_key)
      keypair.public_encrypt(data)
    rescue StandardError
      nil
    end

    def decrypt(data, private_key)
      keypair = OpenSSL::PKey::RSA.new(private_key)
      keypair.private_decrypt(data)
    rescue StandardError
      nil
    end

    def validate_keypair(private_key, public_key)
      data = 'message'
      rsa_encrypted_data = encrypt(data, public_key)
      unless data == decrypt(rsa_encrypted_data, private_key)
        raise Exceptions::DecryptFailed
      end
    end

    def generate_new_keypair
      OpenSSL::PKey::RSA.new(2048)
    end
  end
end
