# frozen_string_literal: true

require 'spec_helper'

migration_dir = 'db/migrate/'

migration_file_name = '20220214135340_move_file_entries_to_encryptable_files.rb'
migration_file = Dir[Rails.root.join(migration_dir + migration_file_name)].first

require migration_file

describe MoveFileEntriesToEncryptableFiles do

  let(:migration) { described_class.new }

  let!(:credentials1) { encryptables(:credentials1) }
  let!(:credentials2) { encryptables(:credentials2) }

  let(:test_file) { file_fixture('test_file.txt') }

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

      @legacy_credentials1 = LegacyCredentialsWithFileEntries.find(credentials1.id)
      @legacy_credentials2 = LegacyCredentialsWithFileEntries.find(credentials2.id)

      attrs_test_file = file_attributes('Description of test file', test_file)

      create_legacy_file_entry(@legacy_credentials1, team1_password, attrs_test_file)
      create_legacy_file_entry(@legacy_credentials2, team1_password, attrs_test_file)
    end

    it 'moves files from credentials to folder' do
      migration.up

      encryptable_file1 = credentials1.encryptable_files.second

      encryptable_file1.decrypt(team1_password)
      expect(encryptable_file1.cleartext_file).to eq(test_file.read)
      expect(encryptable_file1.name).to eq('test_file.txt')
      expect(encryptable_file1.content_type).to eq('text/plain')
      expect(encryptable_file1.description).to eq('Description of test file')

      encryptable_file2 = credentials2.encryptable_files.first

      encryptable_file2.decrypt(team1_password)
      expect(encryptable_file2.cleartext_file).to eq(test_file.read)
      expect(encryptable_file2.name).to eq('test_file.txt')
      expect(encryptable_file2.content_type).to eq('text/plain')
      expect(encryptable_file2.description).to eq('Description of test file')
    end

  end

  context 'down' do
    before do
      @file1 = Encryptable::File.new(name: 'test_file.txt',
                                     description: 'Description of test file',
                                     content_type: 'text/plain',
                                     encryptable_credential: credentials1)

      @file1.cleartext_file = test_file.read
      @file1.encrypt(team1_password)
      @file1.save!

      @file2 = Encryptable::File.new(name: 'test_file.txt',
                                     description: 'Description of test file',
                                     content_type: 'text/plain',
                                     encryptable_credential: credentials2)

      @file2.cleartext_file = test_file.read
      @file2.encrypt(team1_password)
      @file2.save!
    end

    it 'moves files from folder to credentials' do
      migration.down

      file_entry1 = FileEntry.where(account_id: credentials1.id).second
      file_entry1.decrypt(team1_password)
      expect(file_entry1.cleartext_file).to eq(test_file.read)
      expect(file_entry1.filename).to eq('test_file.txt')
      expect(file_entry1.description).to eq('Description of test file')

      file_entry2 = FileEntry.find_by(account_id: credentials2.id)
      file_entry2.decrypt(team1_password)
      expect(file_entry2.cleartext_file).to eq(test_file.read)
      expect(file_entry2.filename).to eq('test_file.txt')
      expect(file_entry2.description).to eq('Description of test file')
    end

  end

  private

  def create_legacy_file_entry(encryptable, team_password, file_attributes)
    file_entry = encryptable.file_entries.new
    file_entry.attributes = file_attributes
    file_entry.encrypt(team_password)
    file_entry.save!
  end

  def file_attributes(description, file)
    {
      description: description,
      filename: file.basename.to_s,
      content_type: 'text/plain',
      cleartext_file: file.read
    }
  end

  # Credentials model as it was before this migration
  # rubocop:disable Lint/ConstantDefinitionInBlock
  class LegacyCredentialsWithFileEntries < Encryptable
    self.inheritance_column = nil

    has_many :file_entries, foreign_key: :account_id, primary_key: :id, dependent: :destroy
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock

  # Legacy FileEntry class
  # rubocop:disable Lint/ConstantDefinitionInBlock
  class FileEntry < ApplicationRecord
    attr_accessor :cleartext_file

    belongs_to :legacy_credentials_with_file_entries, primary_key: :id, foreign_key: :account_id

    self.table_name = 'file_entries'

    def encrypt(team_password)
      return if cleartext_file.blank?

      self.file = ::Crypto::Symmetric::Aes256.encrypt(cleartext_file, team_password)
    end

    def decrypt(team_password)
      return if file.blank?

      encrypted_values = { data: file, iv: nil }
      self.cleartext_file = ::Crypto::Symmetric::Aes256.decrypt(encrypted_values, team_password)
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock

end
