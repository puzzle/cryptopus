# frozen_string_literal: true

require 'rails_helper'
describe Teammember do

  let(:user) { users(:bob) }

  context 'new' do
    it 'does not add second user in same team' do
      params = {
        user_id: users(:alice).id,
        team_id: teams(:team1).id
      }
      teammember = Teammember.new(params)
      expect(teammember).to_not be_valid
    end

    it 'can add second user' do
      params = {
        user_id: users(:admin).id,
        team_id: teams(:team2).id
      }
      params2 = {
        user_id: users(:alice).id,
        team_id: teams(:team2).id
      }

      teammember = Teammember.new(params)
      teammember2 = Teammember.new(params2)
      expect(teammember).to be_valid
      expect(teammember2).to be_valid
    end
  end

  context 'new' do
    it 'cannot remove last teammember' do
      team2_bob = teammembers(:team2_bob)

      team2_bob.destroy

      expect(team2_bob).to be_persisted
      expect(team2_bob.errors[:base].first).to match(/Cannot remove last teammember/)
    end

    it 'cannot remove admin user from non private team' do
      team1_admin = teammembers(:team1_admin)

      team1_admin.destroy

      expect(team1_admin).to be_persisted
      expect(team1_admin.errors[:base].first)
        .to match(/Admin user cannot be removed from non private team/)
    end

    it 'remove teammember' do
      team1_bob = teammembers(:team1_bob)
      team1_bob.destroy!
      expect(team1_bob).to be_destroyed
    end

    it 'remove teammember and his api users from team' do
      team = teams(:team1)
      api_user = user.api_users.create

      bobs_private_key = user.decrypt_private_key('password')
      plaintext_team_password = teams(:team1).decrypt_team_password(user, bobs_private_key)

      team.add_user(api_user, plaintext_team_password)

      team1_bob = teammembers(:team1_bob)
      team1_bob.destroy!
      expect(team1_bob).to be_destroyed
      expect(team.teammember?(api_user)).to eq(false)
    end
  end

  it 'can add api user' do
    api_user = user.api_users.create

    bobs_private_key = user.decrypt_private_key('password')
    plaintext_team_password = teams(:team1).decrypt_team_password(user, bobs_private_key)

    teams(:team1).add_user(api_user, plaintext_team_password)

    team = teams(:team1)
    expect(team.teammember?(api_user)).to eq(true)
  end
end
