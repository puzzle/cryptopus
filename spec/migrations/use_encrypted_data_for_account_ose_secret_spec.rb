# frozen_string_literal: true

require 'spec_helper'

migration_dir = 'db/migrate/'
migration_file_name = '20220107115502_use_encrypted_data_for_account_ose_secret.rb'
mig_file = Dir[Rails.root.join(migration_dir + migration_file_name)].first
require mig_file

describe UseEncryptedDataForAccountOseSecret do

  let(:migration) { described_class.new }
  let(:folder1) { folders(:folder1) }

  let(:ose_secret_iv_decoded) { Base64.strict_decode64('Q1pJ4sr1X1znYUwOJ8F8UQ==') }
  let(:ose_secret_data) {  }

  def silent
    verbose = ActiveRecord::Migration.verbose = false

    yield

    ActiveRecord::Migration.verbose = verbose
  end

  around do |test|
    silent { test.run }
  end

  context 'up' do
    before do
      migration.down
      @ose_secret_account = LegacyOSESecret.create!(name: 'secret1',
                                            folder_id: folder1.id,
                                            type: "Account::OSESecret",
                                            ose_secret: decoded_secret)

      @ose_secret_account.encrypt(team1_password)
      @ose_secret_account.save
    end

    it 'migrates ose_secret credentials to EncryptedData with base64 encoding' do
      migration.up

      ose_secret_account = Account.find(@ose_secret_account.id)
      ose_secret_account.decrypt(team1_password)

      expect(ose_secret_account.ose_secret).to eq(decoded_secret)
    end
  end

  context 'down' do
    after { migration.up }

    it 'reverts to previous schema' do
      ose_secret_account = Account::OSESecret.create!(name: 'secret1',
                                                     folder_id: folder1.id,
                                                     ose_secret: decoded_secret)
      legacy_secret_account = LegacyOSESecret.create!(name: 'legacy_secret1',
                                                    folder_id: folder1.id,
                                                    type: "Account::OSESecret",
                                                    ose_secret: decoded_secret)

      ose_secret_account.encrypt(team1_password)
      ose_secret_account.save

      legacy_secret_account.encrypt(team1_password)
      legacy_secret_account.save

      iv = ose_secret_account.encrypted_data[:ose_secret][:iv]
      legacy_iv = iv_from_account(legacy_secret_account)

      migration.down

      LegacyOSESecret.reset_column_information

      ose_secret_account = LegacyOSESecret.find(ose_secret_account.id)
      legacy_secret_account.reload

      ose_secret_account.decrypt(team1_password)
      legacy_secret_account.decrypt(team1_password)

      expect(ose_secret_account.decoded_secret).to eq(decoded_secret)
      expect(legacy_secret_account.decoded_secret).to eq(decoded_secret)
    end
  end


  private

  def decoded_secret
    Base64.strict_decode64(FixturesHelper.read_account_file('example_secret.secret'))
  end

  def iv_from_account(account)
    iv_b64 = JSON.parse(account.encrypted_data, symbolize_names: true)[:iv]
    Base64.strict_decode64(iv_b64)
  end

  class LegacyOSESecret < ApplicationRecord
    self.table_name = 'accounts'
    self.inheritance_column = nil

    attr_accessor :ose_secret, :iv, :value

    def decrypt(team_password)
      decrypted_json = CryptUtils.decrypt_data(self.value, team_password, Base64.strict_decode64(self.iv))
      decrypted_data = JSON.parse(decrypted_json, symbolize_names: true)

      self.ose_secret = decrypted_data[:ose_secret]
    end

    def encrypt(team_password)
      encrypted_data_hash = { ose_secret: self.ose_secret }
      self.value, self.iv = CryptUtils.encrypt_data(encrypted_data_hash.to_json, team_password)
      self.encrypted_data = legacy_encrypted_data_json(Base64.strict_encode64(self.iv), Base64.strict_encode64(self.value))
    end

    private

    def legacy_encrypted_data_json(iv, value)
        { iv: iv, value: value }.to_json
    end
  end
end
