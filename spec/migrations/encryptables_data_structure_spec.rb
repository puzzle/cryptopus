# frozen_string_literal: true

require 'spec_helper'
mig_file = Dir[Rails.root.join('db/migrate/20220104140658_use_encrypted_data_for_account_credentials.rb')].first
require mig_file

describe UseEncryptedDataForAccountCredentials do

  let(:migration) { described_class.new }

  let(:folder1) {folders(:folder1)}

  let(:account1) {accounts(:account1)}
  let(:account2) {accounts(:account2)}
  let!(:account3) do
    Account::Credentials.create!(name: 'spacex', folder: folder1, encrypted_data: {
      password: {data: '', iv: nil},
      username: {data: nil, iv: nil}
    })
  end


  def silent
    verbose = ActiveRecord::Migration.verbose = false

    yield

    ActiveRecord::Migration.verbose = verbose
  end

  around do |test|
    silent { test.run }
  end

  context 'up' do
    before { migration.down }

    it 'migrates blob credentials to base64' do
      migration.up

      # account 1
      account1.reload

      raw_encrypted_data = account1.read_attribute_before_type_cast(:encrypted_data)
      expect(raw_encrypted_data).to eq('{\"password\":{\"iv\":null,\"data\":\"pulO7xz5jDwUVQzbOqJzIw==\"},\"username\":{\"iv\":null,\"data\":\"0CkUu2Bd9eNB4OCuXVC3TA==\"}}')

      account1.decrypt(team1_password)

      expect(account1.cleartext_username).to eq('test')
      expect(account1.cleartext_password).to eq('password')

      # account 2
      account2.reload

      raw_encrypted_data = account2.read_attribute_before_type_cast(:encrypted_data)
      expect(raw_encrypted_data).to eq('{\"password\":{\"iv\":null,\"data\":\"X2i8woXXwIHew6zcnBws9Q==\"},\"username\":{\"iv\":null,\"data\":\"Kvkd66uUiNq4Gw4Yh7PvVg==\"}}')

      account2.decrypt(team2_password)

      expect(account2.cleartext_username).to eq('test2')
      expect(account2.cleartext_password).to eq('password')

      # account 3
      account3.reload

      raw_encrypted_data = account3.read_attribute_before_type_cast(:encrypted_data)
      expect(raw_encrypted_data).to eq('{}')

      account3.decrypt(team1_password)

      expect(account3.cleartext_username).to eq(nil)
      expect(account3.cleartext_password).to eq(nil)

      expect do
        account1.username
        account1.password
      end.to raise_error(ActiveModel::MissingAttributeError)
    end

  end

  context 'down' do
    after { migration.up }

    it 'reverts to previous schema' do
      migration.down

      # account 1

      account1.reload
      legacy_account = UseEncryptedDataForAccountCredentials::
                       LegacyAccount::
                       Credentials.find(account1.id)

      raw_encrypted_data = account1.read_attribute_before_type_cast(:encrypted_data)
      expect(raw_encrypted_data).to eq('{}')

      legacy_account.decrypt(team1_password)

      expect(legacy_account.cleartext_username).to eq('test')
      expect(legacy_account.cleartext_password).to eq('password')

      # account 2

      account2.reload
      legacy_account = UseEncryptedDataForAccountCredentials::
                       LegacyAccount::
                       Credentials.find(account2.id)

      raw_encrypted_data = account2.read_attribute_before_type_cast(:encrypted_data)
      expect(raw_encrypted_data).to eq('{}')

      legacy_account.decrypt(team2_password)

      expect(legacy_account.cleartext_username).to eq('test2')
      expect(legacy_account.cleartext_password).to eq('password')

      # account 3

      account3.reload
      legacy_account = UseEncryptedDataForAccountCredentials::
                       LegacyAccount::
                       Credentials.find_by(id: account3.id)

      raw_encrypted_data = account3.read_attribute_before_type_cast(:encrypted_data)
      expect(raw_encrypted_data).to eq('{}')

      legacy_account.decrypt(team1_password)

      expect(legacy_account.cleartext_username).to eq(nil)
      expect(legacy_account.cleartext_password).to eq(nil)
    end
  end

end
