# frozen_string_literal: true

class Account::EncryptedData
  include JsonSerializable

  attr_accessor :data, :iv

  def initialize(data: nil, iv: nil)
    @data = data
    @iv = iv
  end

  def self.encrypt(encryption_key, data)
    iv = CryptUtils.random_iv
    new(data: CryptUtils.encrypt_base64(data, encryption_key, iv),
        iv: Base64.strict_encode64(iv))
  end

  def decrypt(encryption_key)
    CryptUtils.decrypt_base64(data, encryption_key, Base64.strict_decode64(iv))
  end
end
