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

  end

  context 'down' do

    it 'renames encryptables table to accounts' do
      migration.down

      legacy_account1 = LegacyAccount.find(credentials1.id)
      legacy_account2 = LegacyAccount.find(credentials2.id)

      expect(legacy_account1.type).to eq('Account::Credentials')
      expect(legacy_account2.type).to eq('Account::Credentials')
    end
  end

end

# Account model as it was after this migration
class LegacyAccount < Encryptable
  self.table_name = 'accounts'
  self.inheritance_column = nil

end
