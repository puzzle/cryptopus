# frozen_string_literal: true

require 'spec_helper'

migration_dir = 'db/migrate/'

migration_file_name = '20220127071750_move_files_from_credential_to_folder.rb'
migration_file = Dir[Rails.root.join(migration_dir + migration_file_name)].first

require migration_file

describe MoveFilesFromCredentialToFolder do

  let(:migration) { described_class.new }

  let!(:folder1) { folders(:folder1) }
  let!(:folder2) { folders(:folder2) }

  let!(:credentials1) { encryptables(:credentials1) }
  let!(:credentials2) { encryptables(:credentials2) }
  let!(:credentials3) do
    Encryptable::Credentials.create!(name: 'Empty Credential', folder: folder2)
  end

  let(:test_file) { file_fixture('test_file.txt') }
  let(:empty_file) { file_fixture('empty.txt') }

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
      @legacy_credentials1 = LegacyCredentialsWithFileEntries.find(credentials1.id)
      @legacy_credentials2 = LegacyCredentialsWithFileEntries.find(credentials2.id)
      @legacy_credentials3 = LegacyCredentialsWithFileEntries.find(credentials3.id)

      attrs_test_file = file_attributes('Description of test file', test_file)
      attrs_empty_file = file_attributes('Description of empty file', empty_file)

      create_legacy_file_entry(@legacy_credentials1, team1_password, attrs_test_file)
      create_legacy_file_entry(@legacy_credentials2, team1_password, attrs_empty_file)
      create_legacy_file_entry(@legacy_credentials3, team1_password, attrs_test_file)
    end

    it 'moves files from credentials to folder' do
      migration.up

      encryptable_file1 = Encryptable::File.find_by(
        folder_id: folder1.id,
        description: 'Description of test file'
      )
      expect(encryptable_file1.decrypt(team1_password)).to eq('certificate')
      expect(encryptable_file1.name).to eq('Personal Mailbox test_file.txt')
      expect(encryptable_file1.description).to eq('Description of test file')


      encryptable_file2 = Encryptable::File.find_by(
        folder_id: folder2.id,
        description: 'Description of empty file'
      )
      expect(encryptable_file2.decrypt(team1_password)).to eq(nil)
      expect(encryptable_file2.name).to eq('Twitter Account empty.txt')
      expect(encryptable_file2.description).to eq('Description of empty file')


      encryptable_file3 = Encryptable::File.find_by(
        folder_id: folder2.id,
        description: 'Description of test file'
      )
      expect(encryptable_file3.decrypt(team1_password)).to eq('certificate')
      expect(encryptable_file3.name).to eq('Empty Credential test_file.txt')
      expect(encryptable_file3.description).to eq('Description of test file')

      expect do
        @legacy_credentials3.reload
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

  end

  private

  def create_legacy_file_entry(encryptable, team_password, file_attributes)
    file_entry = encryptable.file_entries.new
    file_entry.attributes = file_attributes
    file_entry.encrypt(team_password)
    file_entry.save
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
  class LegacyCredentialsWithFileEntries < Encryptable
    self.inheritance_column = nil

    has_many :file_entries, foreign_key: :account_id, primary_key: :id, dependent: :destroy
  end

  # Legacy FileEntry class
  class FileEntry < ApplicationRecord
    attr_accessor :cleartext_file

    belongs_to :legacy_credentials_with_file_entries, primary_key: :id, foreign_key: :account_id

    self.table_name = 'file_entries'

    # rubocop:disable Rails/Blank
    def encrypt(team_password)
      return if cleartext_file.nil? || cleartext_file.empty?

      self.file = CryptUtils.encrypt_blob(cleartext_file, team_password)
    end
    # rubocop:enable Rails/Blank

  end

end
