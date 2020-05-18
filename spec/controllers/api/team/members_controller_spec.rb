# frozen_string_literal: true

require 'rails_helper'

describe Api::Teams::MembersController do
  include ControllerHelpers

  let(:bob) { users(:bob) }

  context 'GET candidates' do
    it 'returns team member candidates for new team' do
      login_as(:admin)
      team = Team.create(users(:admin), name: 'foo')

      get :candidates, params: { team_id: team }, xhr: true

      candidates = json['data']['user/humen']

      expect(candidates.size).to eq 3
      expect(candidates.any? { |c| c['label'] == 'Alice test' }).to be true
      expect(candidates.any? { |c| c['label'] == 'Bob test' }).to be true
      expect(candidates.any? { |c| c['label'] == 'Tux Miller' }).to be true
    end
  end

  context 'GET index' do
    it 'returns team members for given team' do
      login_as(:admin)

      team = teams(:team1)
      teammembers(:team1_bob).destroy!
      user = users(:alice)

      api_user = user.api_users.create!
      alices_private_key = user.decrypt_private_key('password')
      plaintext_team_password = team.decrypt_team_password(user, alices_private_key)

      team.add_user(api_user, plaintext_team_password)

      get :index, params: { team_id: team }, xhr: true

      members = JSON.parse(response.body)['data']['teammembers']

      expect(members.size).to eq 3
      expect(members.any? { |c| c['label'] == 'Alice test' }).to be true
      expect(members.any? { |c| c['label'] == 'Admin test' }).to be true
      expect(members.none? { |c| c['label'] == api_user.label }).to be true
    end
  end

  context 'POST create' do
    it 'creates new teammember for given team' do
      login_as(:admin)
      team = teams(:team1)
      user = Fabricate(:user)

      post :create, params: { team_id: team, teammember: { user_id: user } }, xhr: true

      expect(team.teammember?(user)).to be true
    end
  end

  context 'DELETE destroy' do
    it 'does not remove admin from non private team' do
      login_as(:alice)

      expect do
        delete :destroy,
               params: { team_id: teams(:team1), id: teammembers(:team1_admin) },
               xhr: true
      end.to raise_error(ActiveRecord::RecordNotDestroyed)
    end

    it 'removes teammember from team' do
      login_as(:alice)
      expect do
        delete :destroy, params: { team_id: teams(:team1), id: teammembers(:team1_bob) }, xhr: true
      end.to change { Teammember.count }.by(-1)
    end

    it 'removes human user and his api users from team' do
      api_user = bob.api_users.create
      bobs_private_key = bob.decrypt_private_key('password')
      plaintext_team_password = teams(:team1).decrypt_team_password(bob, bobs_private_key)

      teams(:team1).add_user(api_user, plaintext_team_password)

      login_as(:alice)
      expect do
        delete :destroy, params: { team_id: teams(:team1), id: teammembers(:team1_bob) }, xhr: true
      end.to change { Teammember.count }.by(-2)
      expect(teams(:team1).teammember?(bob)).to eq false
      expect(teams(:team1).teammember?(api_user)).to eq false
    end
  end
end
