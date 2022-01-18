# frozen_string_literal: true

require 'spec_helper'

migration_dir = 'db/migrate/'

migration_file_name = '20220113085536_rename_accounts_to_encryptables.rb'
migration_file = Dir[Rails.root.join(migration_dir + migration_file_name)].first

require migration_file

describe RenameAccountsToEncryptables do

  let(:migration) { described_class.new }

  let!(:credentials1) { encryptables(:credentials1) }
  let!(:credentials2) { encryptables(:credentials2) }

  let!(:ose_secret) { create_ose_secret }

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
    end

    it 'renames accounts table to encryptables' do
      migration.up

      ose_secret.reload

      expect(ose_secret.type).to eq('Encryptable::OSESecret')
      expect(credentials1.reload.type).to eq('Encryptable::Credentials')
      expect(credentials2.reload.type).to eq('Encryptable::Credentials')
    end

  end

  context 'down' do

    it 'renames encryptables table to accounts' do
      migration.down

      legacy_ose_secret = LegacyAccount.find(ose_secret.id)
      legacy_account1 = LegacyAccount.find(credentials1.id)
      legacy_account2 = LegacyAccount.find(credentials2.id)

      expect(legacy_ose_secret.type).to eq('Account::OSESecret')
      expect(legacy_account1.type).to eq('Account::Credentials')
      expect(legacy_account2.type).to eq('Account::Credentials')
    end
  end

  private

  def create_ose_secret
    secret = Encryptable::OSESecret.new(name: 'RSA Key',
                                        folder: folders(:folder1),
                                        cleartext_ose_secret: example_ose_secret_yaml)

    secret.encrypt(team1_password)
    secret.save!
    secret
  end

  def example_ose_secret_yaml
    Base64.strict_decode64(FixturesHelper.read_encryptable_file('example_secret.secret'))
  end

  # Account model as it was after this migration
  class LegacyAccount < Encryptable
    self.table_name = 'accounts'
    self.inheritance_column = nil

  end
end
