# frozen_string_literal: true

class Account::OSESecret < Account
  attr_accessor :ose_secret

  def decrypt(team_password)
    decrypted_json = encrypted_data.decrypt(team_password)
    decrypted_data = JSON.parse(decrypted_json, symbolize_names: true)

    self.ose_secret = decrypted_data[:ose_secret]
  end

  def encrypt(team_password)
    self.encrypted_data = Account::EncryptedData.encrypt(team_password,
                                                         { ose_secret: ose_secret }.to_json)
  end

  private

  def decrypt_data(team_password)
    return if encrypted_data.blank?

    CryptUtils.decrypt_base64(encrypted_data, team_password)
  end

  def encrypt_data(team_password)
    return if data.blank?

    self.encrypted_data = CryptUtils.encrypt_base64(data, team_password)
  end
end
