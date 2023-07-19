# frozen_string_literal: true

require 'spec_helper'

describe Crypto::Symmetric::Recrypt do
  let(:admin) { users(:admin) }
  let(:bob) { users(:admin) }
  let(:admin_pk) { admin.decrypt_private_key('password') }
  let(:bob_pk) { bob.decrypt_private_key('password') }
  let(:fabricate_team) { Fabricate(:non_private_team) }
  let(:old_algo_team) { Fabricate(:old_encryption_algo_team) }

  it 'does recrypt team encryptable if only token is set as attribute' do
    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256')

    expect(old_algo_team).to be_persisted
    expect(old_algo_team.read_attribute(:encryption_algorithm)).to eq 'AES256'
    expect(old_algo_team.encryption_algorithm).to eq 'AES256'
    expect(old_algo_team.recrypt_state).to eq 'done'

    team_password = old_algo_team.decrypt_team_password(admin, admin_pk)
    encryptable = old_algo_team.encryptables.first
    encryptable.decrypt(team_password)
    encryptable_token = encryptable.cleartext_token
    expect(encryptable_token).to be_present

    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256IV')

    described_class.new(admin, old_algo_team, admin_pk).perform

    old_algo_team.reload
    expect(old_algo_team.read_attribute(:encryption_algorithm)).to eq 'AES256IV'
    expect(old_algo_team.encryption_algorithm).to eq 'AES256IV'
    expect(old_algo_team.recrypt_state).to eq 'done'

    encryptable = Encryptable.find(encryptable.id)
    new_team_password = old_algo_team.decrypt_team_password(admin, admin_pk)
    expect(new_team_password).not_to eq(team_password)
    encryptable.decrypt(new_team_password)
    expect(encryptable.cleartext_token).to eq(encryptable_token)

    encrypted_data = encryptable.encrypted_data
    expect(encrypted_data[:token][:iv]).to be_present
  end

  it 'does recrypt team encryptable if all attributes are set' do
    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256')

    expect(fabricate_team).to be_persisted
    expect(fabricate_team.read_attribute(:encryption_algorithm)).to eq 'AES256'
    expect(fabricate_team.encryption_algorithm).to eq 'AES256'
    expect(fabricate_team.recrypt_state).to eq 'done'

    team_password = fabricate_team.decrypt_team_password(admin, admin_pk)
    encryptable = fabricate_team.encryptables.first
    encryptable.decrypt(team_password)
    encryptable_username = encryptable.cleartext_username
    encryptable_password = encryptable.cleartext_password
    encryptable_token = encryptable.cleartext_token
    encryptable_pin = encryptable.cleartext_pin
    encryptable_email = encryptable.cleartext_email
    encryptable_custom_label = encryptable.cleartext_custom_attr_label
    encryptable_custom_attr = encryptable.cleartext_custom_attr
    expect(encryptable_username).to be_present
    expect(encryptable_password).to be_present
    expect(encryptable_token).to be_present
    expect(encryptable_pin).to be_present
    expect(encryptable_email).to be_present
    expect(encryptable_custom_label).to be_present
    expect(encryptable_custom_attr).to be_present

    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256IV')

    described_class.new(admin, fabricate_team, admin_pk).perform

    fabricate_team.reload
    expect(fabricate_team.read_attribute(:encryption_algorithm)).to eq 'AES256IV'
    expect(fabricate_team.encryption_algorithm).to eq 'AES256IV'
    expect(fabricate_team.recrypt_state).to eq 'done'

    encryptable = Encryptable.find(encryptable.id)
    new_team_password = fabricate_team.decrypt_team_password(admin, admin_pk)
    expect(new_team_password).not_to eq(team_password)
    encryptable.decrypt(new_team_password)

    expect(encryptable.cleartext_username).to eq(encryptable_username)
    expect(encryptable.cleartext_password).to eq(encryptable_password)
    expect(encryptable.cleartext_token).to eq(encryptable_token)
    expect(encryptable.cleartext_pin).to eq(encryptable_pin)
    expect(encryptable.cleartext_email).to eq(encryptable_email)
    expect(encryptable.cleartext_custom_attr_label).to eq(encryptable_custom_label)
    expect(encryptable.cleartext_custom_attr).to eq(encryptable_custom_attr)

    encrypted_data = encryptable.encrypted_data
    expect(encrypted_data[:username][:iv]).to be_present
    expect(encrypted_data[:password][:iv]).to be_present
    expect(encrypted_data[:token][:iv]).to be_present
    expect(encrypted_data[:pin][:iv]).to be_present
    expect(encrypted_data[:email][:iv]).to be_present
    expect(encrypted_data[:custom_attr][:iv]).to be_present
  end

  it 'does recrypt team encryptable if no attribute is set' do
    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256')

    expect(old_algo_team).to be_persisted
    expect(old_algo_team.read_attribute(:encryption_algorithm)).to eq 'AES256'
    expect(old_algo_team.encryption_algorithm).to eq 'AES256'
    expect(old_algo_team.recrypt_state).to eq 'done'

    team_password = old_algo_team.decrypt_team_password(admin, admin_pk)
    encryptable = old_algo_team.encryptables.last
    encryptable.decrypt(team_password)
    encryptable_token = encryptable.cleartext_token
    expect(encryptable_token).to be_nil

    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256IV')

    described_class.new(admin, old_algo_team, admin_pk).perform

    old_algo_team.reload
    expect(old_algo_team.read_attribute(:encryption_algorithm)).to eq 'AES256IV'
    expect(old_algo_team.encryption_algorithm).to eq 'AES256IV'
    expect(old_algo_team.recrypt_state).to eq 'done'

    encryptable = Encryptable.find(encryptable.id)
    new_team_password = old_algo_team.decrypt_team_password(admin, admin_pk)
    expect(new_team_password).not_to eq(team_password)
    encryptable.decrypt(new_team_password)
    expect(encryptable.cleartext_token).to eq(encryptable_token)

    encrypted_data = encryptable.encrypted_data
    expect(encrypted_data[:username]).to be_nil
    expect(encrypted_data[:password]).to be_nil
    expect(encrypted_data[:pin]).to be_nil
    expect(encrypted_data[:token]).to be_nil
    expect(encrypted_data[:email]).to be_nil
  end

  it 'does not recrypt team encryptables if default algorithm is already in use' do
    expect(fabricate_team).to be_persisted
    # make sure encryption algorithm is persisted
    expect(fabricate_team.read_attribute(:encryption_algorithm)).to eq 'AES256IV'
    expect(fabricate_team.encryption_algorithm).to eq 'AES256IV'
    expect(fabricate_team.recrypt_state).to eq 'done'

    team_password = fabricate_team.decrypt_team_password(admin, admin_pk)
    encryptable = fabricate_team.encryptables.where.not(name: 'broken encryptable').first
    encryptable.decrypt(team_password)

    username = encryptable.cleartext_username
    password = encryptable.cleartext_password

    described_class.new(admin, fabricate_team, admin_pk).perform

    expect(fabricate_team.encryption_algorithm).to eq 'AES256IV'
    expect(fabricate_team.recrypt_state).to eq 'done'

    encryptable.reload.decrypt(team_password)

    expect(encryptable.cleartext_username).to eq(username)
    expect(encryptable.cleartext_password).to eq(password)
  end

  it 'aborts recrypt if error occurs' do
    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256')

    create_broken_encryptable(fabricate_team)

    team_password = fabricate_team.decrypt_team_password(admin, admin_pk)
    encryptable = fabricate_team.encryptables.where.not(name: 'broken encryptable').first

    encryptable.decrypt(team_password)
    username = encryptable.cleartext_username
    password = encryptable.cleartext_password

    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256IV')

    expect do
      described_class.new(admin, fabricate_team, admin_pk).perform
    end.to raise_error(RuntimeError, 'Recrypt failed: wrong final block length')

    expect(fabricate_team.reload.encryption_algorithm).to eq 'AES256'
    expect(fabricate_team.recrypt_state).to eq 'failed'

    encryptable.reload.decrypt(team_password)

    expect(encryptable.cleartext_username).to eq(username)
    expect(encryptable.cleartext_password).to eq(password)
  end

  it 'resets teampassword with a newly generated for each teammember' do
    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256')

    old_team_passwords = fabricate_team.teammembers.pluck(:encrypted_team_password)

    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256IV')

    described_class.new(admin, fabricate_team, admin_pk).perform

    new_team_passwords = fabricate_team.teammembers.pluck(:encrypted_team_password)

    expect(new_team_passwords).not_to eq(old_team_passwords)
  end

  it 'recrypts nested encryptable files' do
    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256')

    team_password = fabricate_team.decrypt_team_password(admin, admin_pk)
    encryptable = fabricate_team.encryptables.first
    file = Fabricate(:file, encryptable_credential: encryptable, team_password: team_password)

    team_password = fabricate_team.decrypt_team_password(admin, admin_pk)
    file.decrypt(team_password)
    cleartext_file = file.cleartext_file
    expect(cleartext_file).to be_present

    stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256IV')

    described_class.new(admin, fabricate_team, admin_pk).perform

    file = Encryptable::File.find(file.id)
    file.decrypt(fabricate_team.decrypt_team_password(admin, admin_pk))

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
