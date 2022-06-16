# frozen_string_literal: true

require_relative '../../utils/crypto/symmetric/aes256iv'

class Encryptable::OseSecret < Encryptable
  attr_accessor :cleartext_ose_secret

  validates :name, uniqueness: { scope: :folder }
  validates :folder_id, presence: true

  def decrypt(team_password)
    convert_legacy_encrypted_data!(team_password) if legacy_encrypted_data?

    decrypt_attr(:ose_secret, team_password)
  end

  def encrypt(team_password)
    encrypt_attr(:ose_secret, team_password)
  end

  private

  # legacy encrypted_data
  #
  # before introduction of Encryptables, ose_secret were stored
  # in a special format inside encrypted_data
  def legacy_encrypted_data?
    legacy_encrypted_data.key?('value')
  end

  def legacy_encrypted_data
    encrypted_data = read_attribute_before_type_cast(:encrypted_data)
    JSON.parse(encrypted_data)
  end

  def convert_legacy_encrypted_data!(team_password)
    json = legacy_encrypted_data
    value = Base64.strict_decode64(json['value'])
    iv = json['iv']

    encrypted_values = { data: value, iv: Base64.strict_decode64(iv) }

    decrypted_data =
      Crypto::Symmetric::Aes256iv.decrypt(encrypted_values, team_password)

    @cleartext_ose_secret = JSON.parse(decrypted_data)['ose_secret']
    self.encrypted_data = {}
    encrypt(team_password)
    save!
  end

end
