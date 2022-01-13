# frozen_string_literal: true

require_relative '../../utils/crypto/symmetric/aes256'

class Account::Credentials < Account
  attr_accessor :cleartext_password, :cleartext_username

  def decrypt(team_password)
    decrypt_attr(:username, team_password)
    decrypt_attr(:password, team_password)
  end

  def encrypt(team_password)
    encrypt_attr(:username, team_password)
    encrypt_attr(:password, team_password)
  end
end
