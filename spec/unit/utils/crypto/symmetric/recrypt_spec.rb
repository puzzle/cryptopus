# frozen_string_literal: true

require 'spec_helper'

describe Crypto::Symmetric::Recrypt do
  let(:admin) { users(:admin) }
  let(:admin_pk) { admin.decrypt_private_key('password') }
  let(:team) { Fabricate(:non_private_team) }

  it 'recrypts encryptables for given team' do
    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256')

    expect(team).to be_persisted
    # make sure encryption algorithm is persisted
    expect(team.read_attribute(:encryption_algorithm)).to eq 'AES256'
    expect(team.encryption_algorithm).to eq 'AES256'
    expect(team.recrypt_state).to eq 'done'

    team_password = team.decrypt_team_password(admin, admin_pk)
    encryptable = team.encryptables.first
    encryptable.decrypt(team_password)
    encryptable_username = encryptable.cleartext_username
    encryptable_password = encryptable.cleartext_password
    expect(encryptable_username).to be_present
    expect(encryptable_password).to be_present

    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256IV')

    described_class.new(admin, team, admin_pk).perform

    team.reload
    expect(team.read_attribute(:encryption_algorithm)).to eq 'AES256IV'
    expect(team.encryption_algorithm).to eq 'AES256IV'
    expect(team.recrypt_state).to eq 'done'

    encryptable = Encryptable.find(encryptable.id)
    new_team_password = team.decrypt_team_password(admin, admin_pk)
    expect(new_team_password).not_to eq(team_password)
    encryptable.decrypt(new_team_password)
    expect(encryptable.cleartext_username).to eq(encryptable_username)
    expect(encryptable.cleartext_password).to eq(encryptable_password)

    encrypted_data = encryptable.encrypted_data
    expect(encrypted_data[:username][:iv]).to be_present
    expect(encrypted_data[:password][:iv]).to be_present
  end

  it 'does not recrypt team encryptables if default algorithm is already in use' do
    expect(team).to be_persisted
    # make sure encryption algorithm is persisted
    expect(team.read_attribute(:encryption_algorithm)).to eq 'AES256IV'
    expect(team.encryption_algorithm).to eq 'AES256IV'
    expect(team.recrypt_state).to eq 'done'

    team_password = team.decrypt_team_password(admin, admin_pk)
    encryptable = team.encryptables.where.not(name: 'broken encryptable').first
    encryptable.decrypt(team_password)

    username = encryptable.cleartext_username
    password = encryptable.cleartext_password

    described_class.new(admin, team, admin_pk).perform

    expect(team.encryption_algorithm).to eq 'AES256IV'
    expect(team.recrypt_state).to eq 'done'

    encryptable.reload.decrypt(team_password)

    expect(encryptable.cleartext_username).to eq(username)
    expect(encryptable.cleartext_password).to eq(password)
  end

  it 'aborts recrypt if error occurs' do
    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256')

    create_broken_encryptable(team)

    team_password = team.decrypt_team_password(admin, admin_pk)
    encryptable = team.encryptables.where.not(name: 'broken encryptable').first

    encryptable.decrypt(team_password)
    username = encryptable.cleartext_username
    password = encryptable.cleartext_password

    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256IV')

    expect do
      described_class.new(admin, team, admin_pk).perform
    end.to raise_error(RuntimeError, 'Recrypt failed: wrong final block length')

    expect(team.reload.encryption_algorithm).to eq 'AES256'
    expect(team.recrypt_state).to eq 'failed'

    encryptable.reload.decrypt(team_password)

    expect(encryptable.cleartext_username).to eq(username)
    expect(encryptable.cleartext_password).to eq(password)
  end

  it 'resets teampassword with a newly generated for each teammember' do
    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256')

    old_team_passwords = team.teammembers.pluck(:encrypted_team_password)

    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256IV')

    described_class.new(admin, team, admin_pk).perform

    new_team_passwords = team.teammembers.pluck(:encrypted_team_password)

    expect(new_team_passwords).not_to eq(old_team_passwords)
  end

  it 'recrypts nested encryptable files' do
    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256')

    team_password = team.decrypt_team_password(admin, admin_pk)
    encryptable = team.encryptables.first
    file = Fabricate(:file, encryptable_credential: encryptable, team_password: team_password)

    team_password = team.decrypt_team_password(admin, admin_pk)
    file.decrypt(team_password)
    cleartext_file = file.cleartext_file
    expect(cleartext_file).to be_present

    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256IV')

    described_class.new(admin, team, admin_pk).perform

    file = Encryptable::File.find(file.id)
    file.decrypt(team.decrypt_team_password(admin, admin_pk))

    expect(file.cleartext_file).to eq(cleartext_file)
  end

  private

  def create_broken_encryptable(team)
    broken_encryptable = Encryptable::Credentials.new
    broken_encryptable.folder = team.folders.first
    broken_encryptable.name = 'broken encryptable'
    broken_encryptable.encrypted_data.[]=(:username, **{ iv: nil, data: 'broken' })
    broken_encryptable.encrypted_data.[]=(:password, **{ iv: nil, data: 'broken' })
    broken_encryptable.save!
  end

end
