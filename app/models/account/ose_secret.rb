# frozen_string_literal: true

class Account::OSESecret < Account
  attr_accessor :ose_secret

  serialize :encrypted_data, ::Account::EncryptedData

  def decrypt(team_password)
    decrypted_json = encrypted_data.decrypt(team_password)
    decrypted_data = JSON.parse(decrypted_json, symbolize_names: true)

    self.ose_secret = decrypted_data[:ose_secret]
  end

  def encrypt(team_password)
    encrypted_data.cleartext_value = { ose_secret: ose_secret }
    encrypted_data.encrypt(team_password)
  end
end
