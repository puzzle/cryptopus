# frozen_string_literal: true

require 'spec_helper'

describe Account::OSESecret do

  let(:folder1) { folders(:folder1) }
  let(:ose_secret_account) do
    Account::OSESecret.create!(name: 'secret1',
                               folder_id: folder1.id,
                               ose_secret: decoded_secret)
  end

  context '#encrypt' do
    it 'encrypts cleartext secret' do
      ose_secret_account.encrypt(team1_password)

      expect(ose_secret_account.encrypted_data[:ose_secret].try(:[], :data)).not_to be(nil)
      expect(ose_secret_account.encrypted_data[:ose_secret].try(:[], :iv)).not_to be(nil)

      # reset ose_secret
      ose_secret_account.ose_secret = nil

      ose_secret_account.decrypt(team1_password)

      # proof that encrypted value equals cleartext value
      expect(ose_secret_account.ose_secret).to eq(decoded_secret)
    end
  end

  context '#decrypt' do
    it 'decrypts encrypted_data ose secret' do
      ose_secret_account.encrypted_data = ::EncryptedData.new(encrypted_data_json)

      ose_secret_account.decrypt(team1_password)

      expect(ose_secret_account.ose_secret).to eq(decoded_secret)
    end

    it 'decrypts encrypted_data ose secret within Hash' do
      ose_secret_account.encrypted_data = ::EncryptedData.new(encrypted_data_json)

      ose_secret_account.decrypt(team1_password)

      expect(ose_secret_account.ose_secret).to eq(decoded_secret)
    end

    it 'decrypts encrypted_data ose secret within Hash with old key' do
      ose_secret_account.encrypted_data = ::EncryptedData.new(encrypted_data_json(true))

      ose_secret_account.decrypt(team1_password)

      expect(ose_secret_account.ose_secret).to eq(decoded_secret)
    end

    # TODO: correct behaviour for legacy hash?
    it 'returns nil when key other than ose_secret' do
      ose_secret_account.encrypted_data = ::EncryptedData.new(encrypted_data_json(true,
                                                                                  :random_key))

      ose_secret_account.decrypt(team1_password)

      expect(ose_secret_account.ose_secret).to eq(nil)
    end
  end

  private

  def decoded_secret
    Base64.strict_decode64(FixturesHelper.read_account_file('example_secret.secret'))
  end

  def encrypted_data_json(legacy = false, legacy_hash_key = :ose_secret)
    data = legacy ? legacy_ose_secret_hash_b64(legacy_hash_key, decoded_secret) : decoded_secret
    data, iv = CryptUtils.encrypt_data(data, team1_password)

    {
      ose_secret: {
        iv: Base64.strict_encode64(iv),
        data: Base64.strict_encode64(data)
      }
    }
  end

  def legacy_ose_secret_hash_b64(key, value)
    legacy_hash = {}
    legacy_hash[key] = value

    legacy_hash.to_json
  end
end
