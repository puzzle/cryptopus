# frozen_string_literal: true

require_relative '../../utils/crypto/symmetric/AES256'

class Account::Credentials < Account
  attr_accessor :cleartext_password, :cleartext_username

  def decrypt(team_password)
    @cleartext_username = decrypt_attr(:username, team_password)
    @cleartext_password = decrypt_attr(:password, team_password)
  end

  def encrypt(team_password)
    encrypt_username(team_password)
    encrypt_password(team_password)
  end

  private

  def decrypt_attr(attr, team_password)
    crypted_value = send(attr)
    return if crypted_value.blank?

    Crypto::Symmetric::AES256.decrypt(crypted_value, team_password)
  end

  def encrypt_username(team_password)
    return self.username = '' if cleartext_username.blank?

    self.username = Crypto::Symmetric::AES256.encrypt(cleartext_username, team_password)
  end

  def encrypt_password(team_password)
    return if cleartext_password.blank?

    self.password = Crypto::Symmetric::AES256.encrypt(cleartext_password, team_password)
  end
end
