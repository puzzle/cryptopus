# frozen_string_literal: true

require 'spec_helper'

describe Api::Teams::MembersController do
  include ControllerHelpers

  let(:bob) { users(:bob) }

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

      expect(data.count).to eq 3
      expect(data.any? { |c| c['attributes']['label'] == 'Alice test' }).to be true
      expect(data.any? { |c| c['attributes']['label'] == 'Admin test' }).to be true
      expect(data.none? { |c| c['attributes']['label'] == api_user.label }).to be true
    end

    it 'returns team members for given team with member of current user flagged' do
      login_as(:alice)

      team = teams(:team1)

      get :index, params: { team_id: team }, xhr: true

      own_team_member = data.select { |member| member['attributes']['current_user'] }.first

      expect(own_team_member).not_to be_nil
      expect(own_team_member['attributes']['label']).to eq('Alice test')
    end

    it 'does not return team members for given team without team membership' do
      login_as(:alice)

      team = teams(:team2)

      get :index, params: { team_id: team }, xhr: true

      expect(response).to have_http_status(403)
    end
  end

  context 'POST create' do
    it 'creates new teammember for given team' do
      login_as(:admin)
      team = teams(:team1)
      user = Fabricate(:user)

      post :create, params: { team_id: team, data: { attributes: { user_id: user } } }, xhr: true

      expect(team.teammember?(user)).to be true
    end

    it 'does not create new teammember for given team without team memberhip' do
      login_as(:alice)
      team = teams(:team2)
      user = users(:alice)

      post :create, params: { team_id: team, data: { attributes: { user_id: user } } }, xhr: true

      expect(response).to have_http_status(403)
    end
  end

  context 'DELETE destroy' do
    it 'does not remove admin from non private team' do
      login_as(:alice)

      expect do
        delete :destroy,
               params: { team_id: teams(:team1), id: teammembers(:team1_admin) },
               xhr: true
      end.to_not(change { Teammember.count })

      expect(json['errors'].first['detail']).to eq('Admin user cannot be '\
                                                   'removed from non private team')
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

    it 'removes human user and his user_favourite_team entry' do
      login_as(:alice)
      expect do
        delete :destroy, params: { team_id: teams(:team1), id: teammembers(:team1_bob) }, xhr: true
      end.to change { UserFavouriteTeam.count }.by(-1)
      expect(teams(:team1).teammember?(bob)).to eq false
    end

    it 'does not remove member from given team without team membership' do
      teammembers(:team1_alice).destroy!

      login_as(:alice)

      delete :destroy, params: { team_id: teams(:team1), id: teammembers(:team1_bob) }, xhr: true

      expect(response).to have_http_status(403)
    end
  end
end
