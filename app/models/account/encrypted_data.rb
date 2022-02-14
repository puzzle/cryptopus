# frozen_string_literal: true

require_relative '../../utils/crypto/symmetric/aes256iv'

class Account::EncryptedData
  include JsonSerializable

  attr_accessor :value, :iv, :cleartext_value

  def initialize(value: nil, iv: nil)
    @value = value
    @iv = iv
  end

  def encrypt(encryption_key)
    value, iv = Crypto::Symmetric::AES256IV.encrypt(cleartext_value.to_json, encryption_key)
    self.value = Base64.strict_encode64(value)
    self.iv = Base64.strict_encode64(iv)
  end

  def decrypt(encryption_key)
    b64_value = Base64.strict_decode64(value)
    b64_iv = Base64.strict_decode64(iv)

    Crypto::Symmetric::AES256IV.decrypt(b64_value, encryption_key, b64_iv)
  end

  def to_json(*_args)
    raise 'data not encrypted' if value_not_encrypted?

    {
      iv: iv,
      value: value
    }.to_json
  end

  private

  def value_not_encrypted?
    cleartext_value.present? && value.nil?
  end
end
