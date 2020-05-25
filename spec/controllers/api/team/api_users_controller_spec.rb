# frozen_string_literal: true

require 'rails_helper'

describe Api::Teams::ApiUsersController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let(:alice) { users(:alice) }
  let(:alices_private_key) { alice.decrypt_private_key('password') }

  context 'GET index' do
    it 'lists his api users as user' do
      api_user1 = bob.api_users.create
      api_user2 = bob.api_users.create
      alice.api_users.create
      team = teams(:team1)

      login_as(:bob)

      get :index, params: { team_id: team }, xhr: true

      expect(data.count).to eq 2
      expect(data.first['attributes']['username']).to eq api_user1.username
      expect(data.second['attributes']['username']).to eq api_user2.username
    end

    it 'cannot list api users if not a teammember' do
      team = teams(:team2)

      login_as(:alice)

      get :index, params: { team_id: team }, xhr: true

      expect(response).to have_http_status(403)
    end
  end

  context 'POST create' do
    it 'enables api user for team as user' do
      api_user1 = bob.api_users.create
      api_user2 = bob.api_users.create
      team = teams(:team1)

      login_as(:bob)

      post :create, params: { team_id: team, id: api_user1.id }, xhr: true

      expect(team.teammember?(api_user1)).to eq true
      expect(team.teammember?(api_user2)).to eq false
    end

    it 'does not enable api user for team if not a teammember' do
      api_user1 = alice.api_users.create
      team = teams(:team2)

      login_as(:alice)

      post :create, params: { team_id: team, id: api_user1.id }, xhr: true

      expect(response).to have_http_status(403)
    end
  end

  context 'DELETE destroy' do
    it 'disables api user for team as user' do
      api_user = bob.api_users.create
      team = teams(:team1)
      plaintext_team_password = team.decrypt_team_password(bob, bobs_private_key)

      login_as(:bob)

      team.add_user(api_user, plaintext_team_password)

      delete :destroy, params: { team_id: team, id: api_user.id }, xhr: true

      expect(team.teammember?(api_user)).to eq false
    end
  end
end
