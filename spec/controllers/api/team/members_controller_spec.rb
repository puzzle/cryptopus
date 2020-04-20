# frozen_string_literal: true

require 'rails_helper'

describe Api::Team::MembersController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:admin) { users(:admin) }
  let(:tux) { users(:conf_admin) }

  context 'GET candidates' do
    it 'returns team member candidates for new team as admin' do
      login_as(:admin)
      team = Team.create(users(:admin), name: 'foo')

      get :candidates, params: { team_id: team }, xhr: true

      candidates = json['data']['user/humen']

      expect(candidates.size).to eq 3
      expect(candidates.any? { |c| c['label'] == 'Alice test' }).to be true
      expect(candidates.any? { |c| c['label'] == 'Bob test' }).to be true
      expect(candidates.any? { |c| c['label'] == 'Tux Miller' }).to be true
    end

    it 'returns team member candidates for new team' do
      login_as(:bob)
      team = Team.create(users(:bob), name: 'foo')

      get :candidates, params: { team_id: team }, xhr: true

      candidates = json['data']['user/humen']

      expect(candidates.size).to eq 2
      expect(candidates.any? { |c| c['label'] == 'Alice test' }).to be true
      expect(candidates.any? { |c| c['label'] == 'Tux Miller' }).to be true
    end

    it 'returns team member candidates for new team as conf admin' do
      login_as(:tux)
      team = Team.create(users(:conf_admin), name: 'foo')

      get :candidates, params: { team_id: team }, xhr: true

      candidates = json['data']['user/humen']

      expect(candidates.size).to eq 2
      expect(candidates.any? { |c| c['label'] == 'Alice test' }).to be true
      expect(candidates.any? { |c| c['label'] == 'Bob test' }).to be true
    end
  end

  context 'GET index' do
    it 'returns team members for given team as admin' do
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

    it 'returns team members for given team as conf admin' do
      login_as(:tux)

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

    it 'cannot return team members for given team' do
      login_as(:bob)

      team = teams(:team1)
      teammembers(:team1_bob).destroy!
      user = users(:alice)

      api_user = user.api_users.create!
      alices_private_key = user.decrypt_private_key('password')
      plaintext_team_password = team.decrypt_team_password(user, alices_private_key)

      team.add_user(api_user, plaintext_team_password)

      get :index, params: { team_id: team }, xhr: true

      expect(response['data']).to eq nil
    end
  end

  context 'POST create' do
    it 'creates new teammember for given team' do
      login_as(:admin)
      team = teams(:team1)
      user = Fabricate(:user)

      post :create, params: { team_id: team, user_id: user }, xhr: true

      expect(team.teammember?(user)).to be true
    end

    it 'creates new teammember for given team as conf admin' do
      login_as(:tux)
      team = teams(:team1)
      user = Fabricate(:user)

      post :create, params: { team_id: team, user_id: user }, xhr: true

      expect(team.teammember?(users(:alice))).to be true
    end

    it 'creates new teammember for given team as user' do
      login_as(:bob)
      team = teams(:team1)
      user = Fabricate(:user)

      post :create, params: { team_id: team, user_id: user }, xhr: true

      expect(team.teammember?(users(:alice))).to be true
    end

    it 'removes api user from team' do
      login_as(:admin)
      team = teams(:team1)
      api_user = bob.api_users.create!(description: 'my sweet api user')

      post :create, params: { team_id: team, user_id: api_user }, xhr: true

      expect do
        delete :destroy, params: { team_id: teams(:team1), id: api_user }, xhr: true
      end.to change { Teammember.count }.by(-1)
    end

    it 'cannot remove api user from team as conf admin' do
      login_as(:tux)
      team = teams(:team1)
      api_user = bob.api_users.create!(description: 'my sweet api user')

      post :create, params: { team_id: team, user_id: api_user }, xhr: true

      expect do
        delete :destroy, params: { team_id: teams(:team1), id: api_user }, xhr: true
      end.to change { Teammember.count }.by(0)
    end

    it 'can remove api user from team as user' do
      login_as(:bob)
      team = teams(:team1)
      api_user = bob.api_users.create!(description: 'my sweet api user')

      post :create, params: { team_id: team, user_id: api_user }, xhr: true

      expect do
        delete :destroy, params: { team_id: teams(:team1), id: api_user }, xhr: true
      end.to change { Teammember.count }.by(-1)
    end

    it 'adds api user to team' do
      login_as(:bob)
      team = teams(:team1)
      api_user = bob.api_users.create!(description: 'my sweet api user')

      post :create, params: { team_id: team, user_id: api_user }, xhr: true

      expect(team.teammember?(api_user)).to be true
    end

    it 'adds api user to team as conf admin' do
      login_as(:tux)
      team = teams(:team1)
      api_user = bob.api_users.create!(description: 'my sweet api user')

      post :create, params: { team_id: team, user_id: api_user }, xhr: true

      expect(team.teammember?(users(:alice))).to be true
    end

    it 'adds api user to team as admin' do
      login_as(:admin)
      team = teams(:team1)
      api_user = bob.api_users.create!(description: 'my sweet api user')

      post :create, params: { team_id: team, user_id: api_user }, xhr: true

      expect(team.teammember?(users(:alice))).to be true
    end
  end

  context 'DELETE destroy' do
    it 'does not remove admin from non private team' do
      login_as(:alice)

      expect do
        delete :destroy, params: { team_id: teams(:team1), id: users(:admin) }, xhr: true
      end.to raise_error(ActiveRecord::RecordNotDestroyed)
    end

    it 'does remove admin from non private team as conf admin' do
      login_as(:tux)

      expect do
        delete :destroy, params: { team_id: teams(:team1), id: users(:admin) }, xhr: true
      end.to change { Teammember.count }.by(0)
    end

    it 'does remove admin from non private team as admin' do
      login_as(:admin)

      expect do
        delete :destroy, params: { team_id: teams(:team1), id: users(:admin) }, xhr: true
      end.to change { Teammember.count }.by(0)
    end

    it 'removes teammember from team' do
      login_as(:alice)
      expect do
        delete :destroy, params: { team_id: teams(:team1), id: bob }, xhr: true
      end.to change { Teammember.count }.by(-1)
    end

    it 'cannot remove teammember from team as conf admin' do
      login_as(:tux)
      expect do
        delete :destroy, params: { team_id: teams(:team1), id: bob }, xhr: true
      end.to change { Teammember.count }.by(0)
    end

    it 'removes teammember from team as admin' do
      login_as(:admin)
      expect do
        delete :destroy, params: { team_id: teams(:team1), id: bob }, xhr: true
      end.to change { Teammember.count }.by(-1)
    end

    it 'removes human user and his api users from team' do
      api_user = bob.api_users.create
      bobs_private_key = bob.decrypt_private_key('password')
      plaintext_team_password = teams(:team1).decrypt_team_password(bob, bobs_private_key)

      teams(:team1).add_user(api_user, plaintext_team_password)

      login_as(:alice)
      expect do
        delete :destroy, params: { team_id: teams(:team1), id: bob }, xhr: true
      end.to change { Teammember.count }.by(-2)
      expect(teams(:team1).teammember?(bob)).to eq false
      expect(teams(:team1).teammember?(api_user)).to eq false
    end

    it 'removes human user and his api users from team as admin' do
      api_user = bob.api_users.create
      bobs_private_key = bob.decrypt_private_key('password')
      plaintext_team_password = teams(:team1).decrypt_team_password(bob, bobs_private_key)

      teams(:team1).add_user(api_user, plaintext_team_password)

      login_as(:admin)
      expect do
        delete :destroy, params: { team_id: teams(:team1), id: bob }, xhr: true
      end.to change { Teammember.count }.by(-2)
      expect(teams(:team1).teammember?(bob)).to eq false
      expect(teams(:team1).teammember?(api_user)).to eq false
    end

    it 'cannot remove human user and his api users from team as conf_admin' do
      api_user = bob.api_users.create
      bobs_private_key = bob.decrypt_private_key('password')
      plaintext_team_password = teams(:team1).decrypt_team_password(bob, bobs_private_key)

      teams(:team1).add_user(api_user, plaintext_team_password)

      login_as(:tux)
      expect do
        delete :destroy, params: { team_id: teams(:team1), id: bob }, xhr: true
      end.to change { Teammember.count }.by(0)
      expect(teams(:team1).teammember?(bob)).to eq true
      expect(teams(:team1).teammember?(api_user)).to eq true
    end
  end
end
