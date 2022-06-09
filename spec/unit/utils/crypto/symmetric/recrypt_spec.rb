# frozen_string_literal: true

require 'spec_helper'

describe Crypto::Symmetric::Recrypt do
  let(:alice) { users(:alice) }

  it 'recrypts given team' do
    team = Team::Shared.create(alice, name: 'Team 1')

    expect(Crypto::Symmetric).to receive(:latest_algorithm)
      .and_return('AES256IV').twice

    expect(team.encryption_algorithm).to eq 'AES256'

    private_key = alice.decrypt_private_key('password')
    described_class.new(alice, team, private_key).perform

    expect(team.encryption_algorithm).to eq 'AES256IV'
    expect(team.recrypt_state).to eq 'done'
  end

  it 'doesnt recrypt team if default algorithm is already in use' do
    expect(Crypto::Symmetric).to receive(:latest_algorithm)
      .and_return('AES256IV').twice

    team = Team::Shared.create(alice, name: 'Team 1')

    private_key = alice.decrypt_private_key('password')
    described_class.new(alice, team, private_key).perform

    expect(team.encryption_algorithm).to eq 'AES256IV'
    expect(team.recrypt_state).to eq 'done'
  end

  it 'aborts recrypt if error occurs' do
    expect(Crypto::Symmetric).to receive(:latest_algorithm)
      .and_return('AES256IV').twice
    team = teams(:team1)
    create_broken_encryptable(team)
    private_key = alice.decrypt_private_key('password')

    expect do
      described_class.new(alice, team, private_key).perform
    end.to raise_error(RuntimeError)

    expect(team.encryption_algorithm).to eq 'AES256'
    expect(team.recrypt_state).to eq 'failed'
  end

  it 'recrypts team encryptables' do
    expect(Crypto::Symmetric).to receive(:latest_algorithm)
      .and_return('AES256IV').exactly(4).times

    team = teams(:team1)

    private_key = alice.decrypt_private_key('password')
    encryptable = team.encryptables.find_by(type: 'Encryptable::Credentials')
    encryptable.decrypt(team.decrypt_team_password(alice, private_key))

    described_class.new(alice, team, private_key).perform

    encryptable_algorithms = team.encryptables.pluck(:encryption_algorithm).uniq

    expect(encryptable_algorithms.length).to eq 1
    expect(encryptable_algorithms.first).to eq 'AES256IV'

    expect(team.encryption_algorithm).to eq 'AES256IV'
    expect(team.recrypt_state).to eq 'done'

    encryptable = team.encryptables.find_by(type: 'Encryptable::Credentials')
    encryptable.decrypt(team.decrypt_team_password(alice, private_key))
    expect(encryptable.cleartext_password).to eq 'password'
    expect(encryptable.cleartext_username).to eq 'test'
  end

  it 'resets teampassword with a newly generated for each teammember' do
    expect(Crypto::Symmetric).to receive(:latest_algorithm)
      .and_return('AES256IV').exactly(4).times

    team = teams(:team1)
    old_team_passwords = team.teammembers.pluck(:password)

    private_key = alice.decrypt_private_key('password')
    described_class.new(alice, team, private_key).perform

    expect(team.teammembers).not_to eq(old_team_passwords)

    expect(team.encryption_algorithm).to eq 'AES256IV'
    expect(team.recrypt_state).to eq 'done'
  end

  private

  def create_broken_encryptable(team)
    broken_encryptable = team.folders.first.encryptables.first
    broken_encryptable.encrypted_data.[]=(:password, **{ iv: nil, data: 'broken' })
    broken_encryptable.save!
  end

end
