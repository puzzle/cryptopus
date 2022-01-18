# frozen_string_literal: true

require 'spec_helper'

migration_dir = 'db/migrate/'

migration_file_name = '20220104140658_use_encrypted_data_for_account_credentials.rb'
migration_file = Dir[Rails.root.join(migration_dir + migration_file_name)].first

rename_accounts_to_enryptables = '20220113085536_rename_accounts_to_encryptables.rb'
rename_migration_file = Dir[Rails.root.join(migration_dir + rename_accounts_to_enryptables)].first

require migration_file
require rename_migration_file

describe UseEncryptedDataForAccountCredentials do

  let(:migration) { described_class.new }

  let!(:folder1) { folders(:folder1) }

  let!(:credentials1) { encryptables(:credentials1) }
  let!(:credentials2) { encryptables(:credentials2) }

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
      rename_accounts_to_encryptables_migration.down
      migration.down

      @account3 = LegacyAccountCredentialsBefore.create!(accountname: 'spacex', username: '',
                                                         password: nil)
    end

    it 'migrates blob credentials to EncryptedData with base64 encoding' do
      migration.up

      # account 1
      account1 = LegacyAccountCredentialsAfter.find(credentials1.id)

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
      account2 = LegacyAccountCredentialsAfter.find(credentials2.id)

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
      account3 = LegacyAccountCredentialsAfter.find(@account3.id)

      raw_encrypted_data = account3.read_attribute_before_type_cast(:encrypted_data)

      expect(raw_encrypted_data).to eq('{}')

      account3.decrypt(team1_password)

      expect(account3.cleartext_username).to eq(nil)
      expect(account3.cleartext_password).to eq(nil)

      LegacyAccountCredentialsAfter.reset_column_information
      expect(LegacyAccountCredentialsAfter.attribute_names).not_to include('username')
      expect(LegacyAccountCredentialsAfter.attribute_names).not_to include('password')
    end

  end

  context 'down' do

    before do
      rename_accounts_to_encryptables_migration.down
    end

    it 'migrates back to encrypted username, password blob fields' do
      @account3 = LegacyAccountCredentialsAfter.create!(name: 'spacex', folder_id: folder1.id)

      migration.down

      # account 1
      legacy_account = LegacyAccountCredentialsBefore.find(credentials1.id)

      raw_encrypted_data = legacy_account.read_attribute_before_type_cast(:encrypted_data)
      expect(raw_encrypted_data).to eq('{}')

      legacy_account.decrypt(team1_password)

      expect(legacy_account.cleartext_username).to eq('test')
      expect(legacy_account.cleartext_password).to eq('password')

      # account 2
      legacy_account = LegacyAccountCredentialsBefore.find(credentials2.id)

      raw_encrypted_data = legacy_account.read_attribute_before_type_cast(:encrypted_data)
      expect(raw_encrypted_data).to eq('{}')

      legacy_account.decrypt(team2_password)

      expect(legacy_account.cleartext_username).to eq('test2')
      expect(legacy_account.cleartext_password).to eq('password')

      # account 3
      legacy_account = LegacyAccountCredentialsBefore.find_by(id: @account3.id)

      raw_encrypted_data = legacy_account.read_attribute_before_type_cast(:encrypted_data)
      expect(raw_encrypted_data).to eq('{}')

      legacy_account.decrypt(team1_password)

      expect(legacy_account.cleartext_username).to eq(nil)
      expect(legacy_account.cleartext_password).to eq(nil)
    end
  end

  private

  # Account model as it was before migration
  class LegacyAccountCredentialsBefore < ApplicationRecord
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

  # Account model as it was after this migration
  class LegacyAccountCredentialsAfter < ApplicationRecord
    self.table_name = 'accounts'
    self.inheritance_column = nil

    serialize :encrypted_data, ::EncryptedData

    attr_accessor :cleartext_password, :cleartext_username

    def decrypt(team_password)
      decrypt_attr(:username, team_password)
      decrypt_attr(:password, team_password)
    end

    def encrypt(team_password)
      encrypt_attr(:username, team_password)
      encrypt_attr(:password, team_password)
    end

    private

    def encrypt_attr(attr, team_password)
      cleartext_value = send(:"cleartext_#{attr}")

      encrypted_value = if cleartext_value.blank?
                          nil
                        else
                          CryptUtils.encrypt_blob(cleartext_value, team_password)
                        end

      encrypted_data[attr] = { data: encrypted_value, iv: nil }
    end

    def decrypt_attr(attr, team_password)
      encrypted_value = encrypted_data[attr].try(:[], :data)

      cleartext_value = if encrypted_value
                          CryptUtils.decrypt_blob(encrypted_value, team_password)
                        end

      instance_variable_set("@cleartext_#{attr}", cleartext_value)
    end
  end

  def rename_accounts_to_encryptables_migration
    ::RenameAccountsToEncryptables.new
  end
end
