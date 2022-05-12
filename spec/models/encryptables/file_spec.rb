# frozen_string_literal: true

require 'spec_helper'

describe Encryptable::File do
  let(:credentials1) { encryptables(:credentials1) }
  let(:test_file) { FixturesHelper.read_file('test_file.txt') }

  it 'validates cleartext_file size' do
    empty_file = FixturesHelper.read_file('empty.txt')

    # validate to save if normal file is allowed
    encryptable_file = Encryptable::File.new(name: 'Acceptable file size',
                                             encryptable_credential: credentials1)
    encryptable_file.cleartext_file = test_file

    expect(encryptable_file.name).to eq('Acceptable file size')
    expect do
      encryptable_file.save!
    end.to change { Encryptable::File.count }.by(1)

    # mock test_file size to be too large to save
    expect(test_file).to receive(:size).and_return(20.megabytes).twice

    encryptable_file.name = 'Too large file'
    encryptable_file.cleartext_file = test_file

    # validate to not save if too large
    expect(encryptable_file.name).to eq('Too large file')
    error_msg = 'Validation failed: The file is too big to upload. (max. 10MB)'
    expect do
      encryptable_file.save!
    end.to raise_error(ActiveRecord::RecordInvalid, error_msg)

    # validate to save if empty file is not allowed
    encryptable_file.name = 'Unacceptable file size'
    encryptable_file.cleartext_file = empty_file
    error_msg = 'Validation failed: File is not allowed to be blank'

    expect(encryptable_file.name).to eq('Unacceptable file size')
    expect do
      encryptable_file.save!
    end.to raise_error(ActiveRecord::RecordInvalid,  error_msg)
  end

  it 'encrypts and decrypts file' do
    encryptable_file = Encryptable::File.new(name: 'Test file',
                                             encryptable_credential: credentials1)
    encryptable_file.cleartext_file = test_file

    encryptable_file.encrypt(team1_password)

    expect do
      encryptable_file.save!
    end.to change { Encryptable::File.count }.by(1)

    encryptable_file = Encryptable::File.find(encryptable_file.id)
    encryptable_file.decrypt(team1_password)

    expect(encryptable_file.cleartext_file).to eq(test_file)
  end
end
