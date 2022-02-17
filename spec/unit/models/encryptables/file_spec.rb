# frozen_string_literal: true

require 'spec_helper'

describe Encryptable::File do
  let(:credentials1) { encryptables(:credentials1) }
  let(:test_file) { FixturesHelper.read_file('test_file.txt') }

  it 'validates cleartext_file size' do
    empty_file = FixturesHelper.read_file('empty.txt')

    # mock test_file size to be too large to save
    expect(test_file).to receive(:size).and_return(20.megabytes)

    encryptable_file = Encryptable::File.new(name: 'Too large file', encryptable_credential: credentials1)
    encryptable_file.cleartext_file = test_file

    # validate to not save if too large
    expect(encryptable_file.name).to eq('Too large file')
    error_msg = 'Validation failed: The file is too big to upload. (max. 10MB)'
    expect do
      encryptable_file.save!
    end.to raise_error(ActiveRecord::RecordInvalid, error_msg)

    # validate to save if file size is in range
    encryptable_file.name = 'Acceptable file size'
    encryptable_file.cleartext_file = empty_file

    expect(encryptable_file.name).to eq('Acceptable file size')
    expect do
      encryptable_file.save!
    end.to change { Encryptable::File.count }.by(1)
  end

  it 'encrypts and decrypts file' do
    encryptable_file = Encryptable::File.new(name: 'Test file', encryptable_credential: credentials1)
    encryptable_file.cleartext_file = test_file

    encryptable_file.encrypt(team1_password)

    expect do
      encryptable_file.save!
    end.to change { Encryptable::File.count }.by(1)

    encryptable_file.reload

    # expect decrypted file to be the same as file
    decrypted_test_file = encryptable_file.decrypt(team1_password)
    expect(decrypted_test_file).to eq(test_file)
  end

  it 'raises no credential error if no parent present' do
    encryptable_file = Encryptable::File.new(name: 'File without parent')
    encryptable_file.cleartext_file = test_file

    encryptable_file.encrypt(team1_password)

    error_msg = 'Validation failed: The file is too big to upload. (max. 10MB)'
    expect do
      encryptable_file.save!
    end.to raise_error(ActiveRecord::RecordInvalid, error_msg)

    encryptable_file.reload

    # expect decrypted file to be the same as file
    decrypted_test_file = encryptable_file.decrypt(team1_password)
    expect(decrypted_test_file).to eq(test_file)
  end
end