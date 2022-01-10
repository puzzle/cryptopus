# frozen_string_literal: true

require 'spec_helper'

migration_dir = 'db/migrate/'
migration_file_name = '20220107115502_use_encrypted_data_for_account_ose_secret.rb'
mig_file = Dir[Rails.root.join(migration_dir + migration_file_name)].first
require mig_file

describe UseEncryptedDataForAccountOseSecret do

  let(:migration) { described_class.new }
  let(:folder1) { folders(:folder1) }

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
                                                    type: 'Account::OSESecret',
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

      ose_secret_account.encrypt(team1_password)
      ose_secret_account.save

      pre_mig_iv = Base64.strict_encode64(ose_secret_account.encrypted_data[:ose_secret][:iv])

      migration.down

      ose_secret_account = LegacyOSESecret.find(ose_secret_account.id)

      ose_secret_account.decrypt(team1_password)

      expect(ose_secret_account.ose_secret).to eq(decoded_secret)

      post_mig_iv = JSON.parse(ose_secret_account.encrypted_data, symbolize_names: true)[:iv]
      expect(pre_mig_iv).to eq(post_mig_iv)
    end
  end

  private

  def decoded_secret
    Base64.strict_decode64(FixturesHelper.read_account_file('example_secret.secret'))
  end

  def attr_from_account(account, attr)
    iv_b64 = JSON.parse(account.encrypted_data, symbolize_names: true)[attr]
    Base64.strict_decode64(iv_b64)
  end

  class LegacyOSESecret < ApplicationRecord
    self.table_name = 'accounts'
    self.inheritance_column = nil

    attr_accessor :ose_secret

    def decrypt(team_password)
      decrypted_json = CryptUtils.decrypt_data(value, team_password, iv)
      decrypted_data = JSON.parse(decrypted_json, symbolize_names: true)

      self.ose_secret = decrypted_data[:ose_secret]
    end

    def encrypt(team_password)
      encrypted_data_hash = { ose_secret: ose_secret }
      value, iv = CryptUtils.encrypt_data(encrypted_data_hash.to_json, team_password)
      self.encrypted_data = legacy_encrypted_data_json(Base64.strict_encode64(iv),
                                                       Base64.strict_encode64(value))
    end

    private

    def iv
      parsed(:iv)
    end

    def value
      parsed(:value)
    end

    def parsed(attr)
      attr_b64 = JSON.parse(encrypted_data, symbolize_names: true)[attr]
      Base64.strict_decode64(attr_b64)
    end

    def legacy_encrypted_data_json(iv, value)
      { iv: iv, value: value }.to_json
    end
  end
end
