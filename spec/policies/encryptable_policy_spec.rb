# frozen_string_literal: true

require 'spec_helper'
describe EncryptablePolicy do
  include PolicyHelper

  let(:credentials2) { encryptables(:credentials2) }
  let(:folder2) { folders(:folder2) }
  let(:team1) { teams(:team1) }
  let(:team2) { teams(:team2) }

  context 'as teammember' do
    it 'can show credential' do
      assert_permit bob, credentials2, :show?
    end

    it 'can destroy credential' do
      assert_permit bob, credentials2, :destroy?
    end
  end

  context 'as non teammember' do
    it 'non teammember cannot show credential' do
      refute_permit alice, credentials2, :show?
    end

    it 'non teammember cannot destroy credential' do
      refute_permit alice, credentials2, :destroy?
    end

  end

  context 'for team' do
    it 'enabled api user can show credential' do
      assert_permit api_bob, credentials2, :show?
    end

    it 'enabled api user cannot destroy credential' do
      refute_permit api_bob, credentials2, :destroy?
    end

  end

  context 'not for team' do
    it 'enabled api user is not allowed to update credential' do
      refute_permit api_alice, credentials2, :update?
    end
  end

  private

  def api_bob
    bobs_private_key = bob.decrypt_private_key('password')
    plaintext_team_password = team2.decrypt_team_password(bob, bobs_private_key)

    api_bob = bob.api_users.create
    team2.add_user(api_bob, plaintext_team_password)
    api_bob
  end

  def api_alice
    alice_private_key = alice.decrypt_private_key('password')
    plaintext_team_password = team1.decrypt_team_password(alice, alice_private_key)

    api_alice = alice.api_users.create
    team1.add_user(api_alice, plaintext_team_password)
    api_alice
  end
end
