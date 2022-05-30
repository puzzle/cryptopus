# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../../app/utils/crypto/symmetric/aes256iv'

describe Crypto::Symmetric::Recrypt do
  let(:alice) { users(:alice) }

  it 'recrypts given team' do
    expect(Crypto::EncryptionAlgorithm).to receive(:latest_algorithm).and_return(:AES256).once
    expect(Crypto::EncryptionAlgorithm).to receive(:latest_algorithm).and_return(:AES256IV)

    team = Team::Shared.create(alice, name: 'Team 1')

    expect(team.encryption_algorithm).to eq 'AES256'

    private_key = alice.decrypt_private_key('password')
    described_class.new(alice, team, private_key).perform

    expect(team.encryption_algorithm).to eq 'AES256IV'
    expect(team.recrypt_state).to eq 'done'
  end

  it 'doesnt recrypt team if default algorithm is already in use' do
    team = Team::Shared.create(alice, name: 'Team 1')

    private_key = alice.decrypt_private_key('password')
    described_class.new(alice, team, private_key).perform

    expect(team.encryption_algorithm).to eq 'AES256IV'
    expect(team.recrypt_state).to eq 'done'
  end

  it 'aborts in transaction if recrypt error suddenly appears' do
    team = mocked_team

    private_key = alice.decrypt_private_key('password')
    expect do
      described_class.new(alice, team, private_key).perform
    end.to raise_error(RuntimeError)

    expect(team.encryption_algorithm).to eq 'AES256'
    expect(team.recrypt_state).to eq 'failed'
  end

  it 'recrypts team encryptables' do
    expect(Crypto::EncryptionAlgorithm).to receive(:latest_algorithm).and_return(:AES256).once
    expect(Crypto::EncryptionAlgorithm).to receive(:latest_algorithm).and_return(:AES256IV)
    require 'pry'; binding.pry unless $pstop
    team = teams(:team1)

    private_key = alice.decrypt_private_key('password')
    described_class.new(alice, team, private_key).perform

    # encryptable_types =  team.folders.pluck(:encryptables)
    require 'pry'; binding.pry

    expect(team.encryption_algorithm).to eq 'AES256IV'
    expect(team.recrypt_state).to eq 'done'
  end

  private

  def mocked_team
    broken_encryptable = teams(:team1)
    broken_encryptable.encrypted_data.[]=(:password, **{iv: nil, data: 'encrypted'})
    broken_encryptable.save
    teams(:team1)
  end

end
