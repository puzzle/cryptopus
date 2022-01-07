# frozen_string_literal: true

class Account::Credentials < Account
  attr_accessor :cleartext_password, :cleartext_username

  serialize :encrypted_data, ::EncryptedData

  def decrypt(team_password)
    decrypt_attr(:username, team_password)
    decrypt_attr(:password, team_password)
  end

  def encrypt(team_password)
    encrypt_attr(:username, team_password)
    encrypt_attr(:password, team_password)
  end

  private

  def encrypt_attr(attr, team_password)
    cleartext_value = send(:"cleartext_#{attr}")

    encrypted_value = if cleartext_value.blank?
                        nil
                      else
                        CryptUtils.encrypt_blob(cleartext_value, team_password)
                      end

    encrypted_data[attr] = { data: encrypted_value, iv: nil }
  end

  def decrypt_attr(attr, team_password)
    encrypted_value = encrypted_data[attr].try(:[], :data)

    cleartext_value = if encrypted_value
                        CryptUtils.decrypt_blob(encrypted_value, team_password)
                      end

    instance_variable_set("@cleartext_#{attr}", cleartext_value)
  end

end
