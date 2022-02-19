# frozen_string_literal: true

require_relative '../../utils/crypto/symmetric/aes256iv'

class Encryptable::OSESecret < Encryptable
  attr_accessor :cleartext_ose_secret

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
    decrypted_data = Crypto::Symmetric::AES256IV.decrypt(value, team_password, Base64.strict_decode64(iv))

    @cleartext_ose_secret = JSON.parse(decrypted_data)['ose_secret']
    self.encrypted_data = {}
    encrypt(team_password)
    save!
  end

end
