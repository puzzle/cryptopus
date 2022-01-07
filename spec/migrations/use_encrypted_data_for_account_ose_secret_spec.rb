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
      @ose_secret = LegacyOSESecret.create!(name: 'secret1',
                                            folder_id: folder1.id,
                                            type: "Account::OSESecret",
                                            ose_secret: decoded_secret)

      @ose_secret.encrypt(team1_password)
      @ose_secret.save
    end

    it 'migrates blob credentials to EncryptedData with base64 encoding' do
      migration.up

      ose_secret = Account.find(@ose_secret.id)
      require 'pry';binding.pry
    end
  end

  context 'down' do
    after { migration.up }

    it 'reverts to previous schema' do
      migration.down

    end
  end


  private

  def decoded_secret
    Base64.strict_decode64(FixturesHelper.read_account_file('example_secret.secret'))
  end

  class LegacyOSESecret < ApplicationRecord
    self.table_name = 'accounts'
    self.inheritance_column = nil

    attr_accessor :ose_secret, :iv, :value

    def decrypt(team_password)
      decrypted_json = CryptUtils.decrypt_base64(self.value, team_password, Base64.strict_decode64(self.iv))
      decrypted_data = JSON.parse(decrypted_json, symbolize_names: true)

      self.ose_secret = decrypted_data[:ose_secret]
    end

    def encrypt(team_password)
      encrypted_data_hash = { ose_secret: self.ose_secret }
      self.value, self.iv = CryptUtils.encrypt_base64(encrypted_data_hash.to_json, team_password)
      self.encrypted_data = encrypted_data_json(Base64.strict_encode64(self.iv), self.value)
    end

    private

    def encrypted_data_json(iv, value)
        { iv: iv, value: value }.to_json
    end
  end
end
