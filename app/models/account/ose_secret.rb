# frozen_string_literal: true

class Account::OSESecret < Account
  attr_accessor :data

  def decrypt(team_password)
    @data = decrypt_data(team_password)
  end

  def encrypt(team_password)
    encrypt_data(team_password)
  end

  private

  def decrypt_data(team_password)
    return if encrypted_data.blank?

    CryptUtils.decrypt_data(encrypted_data, team_password)
  end

  def encrypt_data(team_password)
    return if data.blank?

    self.encrypted_data = CryptUtils.encrypt_data(data, team_password)
  end
end
