# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../app/utils/sharing/encryptable'
require_relative '../../../../app/controllers/api_controller'

describe Encryptable::Sharing do

  let(:encryptable) { encryptables(:credentials1) }
  let(:alice) { users(:alice) }
  let(:bob) { users(:bob) }
  let(:team1) { teams(:team1) }



  it 'share encryptable with other user' do
    options = {
      current_user: alice,
      decrypted_team_password: team1.decrypt_team_password(alice, alice.decrypt_private_key('password'))
    }

    duplicated_encryptable = Encryptable::Sharing.new(encryptable, bob.id, options).prepare_encryptable

    expect(duplicated_encryptable.receiver_id).to eq(bob.id)
    expect(duplicated_encryptable.transfer_password).to be_present
  end
end
