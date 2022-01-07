# frozen_string_literal: true

require 'spec_helper'

migration_dir = 'db/migrate/'
migration_file_name = '20220104140658_use_encrypted_data_for_account_credentials.rb'
mig_file = Dir[Rails.root.join(migration_dir + migration_file_name)].first
require mig_file

describe UseEncryptedDataForAccountCredentials do

  let(:migration) { described_class.new }

  let(:folder1) { folders(:folder1) }

  let(:account1) { accounts(:account1) }
  let(:account2) { accounts(:account2) }

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
      @account3 = LegacyAccountCredentials.create!(accountname: 'spacex', username: '',
                                                   password: nil)
    end

    it 'migrates blob credentials to EncryptedData with base64 encoding' do

      migration.up

      # account 1
      account1.reload

      raw_encrypted_data = account1.read_attribute_before_type_cast(:encrypted_data)
      encrypted_data_hash = {
        password: { iv: nil, data: 'pulO7xz5jDwUVQzbOqJzIw==' },
        username: { iv: nil, data: '0CkUu2Bd9eNB4OCuXVC3TA==' }
      }

      expect(raw_encrypted_data).to eq(encrypted_data_hash.to_json)

      account1.decrypt(team1_password)

      expect(account1.cleartext_username).to eq('test')
      expect(account1.cleartext_password).to eq('password')

      # account 2
      account2.reload

      raw_encrypted_data = account2.read_attribute_before_type_cast(:encrypted_data)
      encrypted_data_hash = {
        password: { iv: nil, data: 'X2i8woXXwIHew6zcnBws9Q==' },
        username: { iv: nil, data: 'Kvkd66uUiNq4Gw4Yh7PvVg==' }
      }

      expect(raw_encrypted_data).to eq(encrypted_data_hash.to_json)

      account2.decrypt(team2_password)

      expect(account2.cleartext_username).to eq('test2')
      expect(account2.cleartext_password).to eq('password')

      # account 3
      account3 = Account::Credentials.find(@account3.id)

      raw_encrypted_data = account3.read_attribute_before_type_cast(:encrypted_data)
      encrypted_data_hash = {}

      expect(raw_encrypted_data).to eq(encrypted_data_hash.to_json)

      account3.decrypt(team1_password)

      expect(account3.cleartext_username).to eq(nil)
      expect(account3.cleartext_password).to eq(nil)

      Account.reset_column_information
      expect(Account.attribute_names).not_to include('username')
      expect(Account.attribute_names).not_to include('password')
    end

  end

  context 'down' do

    after { migration.up }

    it 'migrates back to encrypted username, password blob fields' do

      account3 = Account::Credentials.create!(name: 'spacex', folder: folder1, encrypted_data: {
                                                password: { data: '', iv: nil },
                                                username: { data: nil, iv: nil }
                                              })

      migration.down

      LegacyAccountCredentials.reset_column_information

      # account 1
      legacy_account = LegacyAccountCredentials.find(account1.id)

      raw_encrypted_data = legacy_account.read_attribute_before_type_cast(:encrypted_data)
      expect(raw_encrypted_data).to eq('{}')

      legacy_account.decrypt(team1_password)

      expect(legacy_account.cleartext_username).to eq('test')
      expect(legacy_account.cleartext_password).to eq('password')

      # account 2
      legacy_account = LegacyAccountCredentials.find(account2.id)

      raw_encrypted_data = legacy_account.read_attribute_before_type_cast(:encrypted_data)
      expect(raw_encrypted_data).to eq('{}')

      legacy_account.decrypt(team2_password)

      expect(legacy_account.cleartext_username).to eq('test2')
      expect(legacy_account.cleartext_password).to eq('password')

      # account 3
      legacy_account = LegacyAccountCredentials.find_by(id: account3.id)

      raw_encrypted_data = legacy_account.read_attribute_before_type_cast(:encrypted_data)
      expect(raw_encrypted_data).to eq('{}')

      legacy_account.decrypt(team1_password)

      expect(legacy_account.cleartext_username).to eq(nil)
      expect(legacy_account.cleartext_password).to eq(nil)
    end
  end

  private

  class LegacyAccountCredentials < ApplicationRecord
    self.table_name = 'accounts'
    self.inheritance_column = nil

    attr_accessor :cleartext_password, :cleartext_username

    def decrypt(team_password)
      @cleartext_username = decrypt_attr(:username, team_password)
      @cleartext_password = decrypt_attr(:password, team_password)
    end

    private

    def decrypt_attr(attr, team_password)
      crypted_value = send(attr)
      return if crypted_value.blank?

      CryptUtils.decrypt_blob(crypted_value, team_password)
    end
  end
end
