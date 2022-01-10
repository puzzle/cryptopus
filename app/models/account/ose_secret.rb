# frozen_string_literal: true

class Account::OSESecret < Account
  attr_accessor :ose_secret

  serialize :encrypted_data, ::EncryptedData

  def decrypt(team_password)
    data = encrypted_data[:ose_secret].try(:[], :data)
    iv = encrypted_data[:ose_secret].try(:[], :iv)

    data = CryptUtils.decrypt_data(data, team_password, iv)

    if legacy_json_hash?(data)
      data = ose_secret_from_hash(JSON.parse(data, symbolize_names: true))
    end

    self.ose_secret = data
  end

  def encrypt(team_password)
    data, iv = CryptUtils.encrypt_data(self.ose_secret, team_password)

    encrypted_data[:ose_secret] = { data: data, iv: iv }
  end

  private

  def legacy_json_hash?(json)
    json = JSON.parse(json)
    json.is_a?(Hash)
  rescue JSON::ParserError => e
    return false
  end

  def ose_secret_from_hash(decrypted_data)
    if decrypted_data.key?(:ose_secret)
      decrypted_data[:ose_secret]
    end
  end
end
