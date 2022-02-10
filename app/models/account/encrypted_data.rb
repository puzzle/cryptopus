# frozen_string_literal: true

class Account::EncryptedData
  include JsonSerializable

  attr_accessor :value, :iv, :cleartext_value

  def initialize(value: nil, iv: nil)
    @value = value
    @iv = iv
  end

  def encrypt(encryption_key)
    value, iv = Symmetric::AES256IV.encrypt(cleartext_value.to_json, encryption_key)
    self.value = value
    self.iv = Base64.strict_encode64(iv)
  end

  def decrypt(encryption_key)
    Symmetric::AES256IV.decrypt(value, encryption_key, Base64.strict_decode64(iv))
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
