# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../../app/utils/crypto/symmetric/aes256iv'

describe Crypto::Symmetric::Recrypt do
  let(:alice) { users(:alice) }

  it 'recrypts given team' do
    expect(Crypto::EncryptionAlgorithm).to receive(:latest).and_return(:AES256)

    team = Team::Shared.create(alice, name: 'Team 1')

    expect(team.encryption_algorithm).to eq 'AES256IV'

    private_key = alice.decrypt_private_key('password')
    described_class.new(alice, team, private_key)

    expect(team.encryption_algorithm).to eq 'AES256IV'
    expect(team.recrypt_state).to eq 'done'
  end

  it 'doesnt recrypt team if default algorithm is already in use' do
    team = Team::Shared.create(alice, name: 'Team 1')

    private_key = alice.decrypt_private_key('password')
    described_class.new(alice, team, private_key)

    expect(team.encryption_algorithm).to eq 'AES256IV'
    expect(team.recrypt_state).to eq 'done'
  end

  it 'aborts in transaction if recrypt error suddenly appears' do
    team = mocked_team

    private_key = alice.decrypt_private_key('password')
    expect do
      described_class.new(alice, team, private_key)
    end.to raise_error(RuntimeError)

    expect(team.encryption_algorithm).to eq 'AES256'
    expect(team.recrypt_state).to eq 'failed'
  end

  it 'recrypts team encryptables' do
    expect(Crypto::EncryptionAlgorithm).to receive(:latest).and_return(:AES256)
    team = teams(:team1)

    private_key = alice.decrypt_private_key('password')
    described_class.new(alice, team, private_key)

    encryptable_types =  team.folders.pluck(:encryptables)
    require 'pry'; binding.pry

    expect(team.encryption_algorithm).to eq 'AES256IV'
    expect(team.recrypt_state).to eq 'done'
  end

  private

  def mocked_team
    defect_encryptable = teams(:team1).folders.first.encryptables.first
    defect_encryptable.encrypted_data.[]=(:password, **{iv: nil, data: 'encrypted'})
    defect_encryptable.save
    teams(:team1)
  end

end
