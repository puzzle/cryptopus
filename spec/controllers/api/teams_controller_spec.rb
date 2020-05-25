# frozen_string_literal: true

require 'rails_helper'

describe Api::TeamsController do
  include ControllerHelpers

  context 'GET index' do
    it 'should get team for search term' do
      login_as(:alice)
      get :index, params: { 'q': 'team' }, xhr: true

      result_json = data.first

      team = teams(:team1)

      expect(result_json['attributes']['name']).to eq team.name
      expect(result_json['id']).to eq team.id.to_s
    end

    it 'should get all teams for no query' do
      login_as(:alice)
      get :index, params: { 'q': '' }, xhr: true

      result_json = data.first

      team = teams(:team1)

      expect(result_json['attributes']['name']).to eq team.name
      expect(result_json['id']).to eq team.id.to_s
    end
  end

  context 'GET last_teammember_teams' do
    it 'returns last teammember teams' do
      login_as(:admin)

      soloteam = Fabricate(:private_team)
      user = soloteam.teammembers.first.user

      get :last_teammember_teams, params: { user_id: user.id }
      team = data.first

      expect(team['id']).to eq soloteam.id.to_s
      expect(team['attributes']['name']).to eq soloteam.name
      expect(team['attributes']['description']).to eq soloteam.description
    end

    it 'returns last teammember teams as conf admin' do
      login_as(:tux)

      soloteam = Fabricate(:private_team)
      user = soloteam.teammembers.first.user

      get :last_teammember_teams, params: { user_id: user.id }
      team = data.first

      expect(team['id']).to eq soloteam.id.to_s
      expect(team['attributes']['name']).to eq soloteam.name
      expect(team['attributes']['description']).to eq soloteam.description
    end

    it 'cannot show last teammember teams if not admin' do
      login_as(:bob)
      soloteam = Fabricate(:private_team)
      user = User.find(soloteam.teammembers.first.user_id)

      get :last_teammember_teams, params: { user_id: user.id }

      expect(errors.first).to eq 'Access denied'
    end

  end

  context 'DELETE destroy' do
    it 'destroys team' do
      login_as(:admin)
      team = Fabricate(:private_team)

      expect do
        delete :destroy, params: { id: team.id }
      end.to change { Team.count }.by(-1)
    end

    it 'cannot delete team if not admin' do
      login_as(:bob)
      soloteam = Fabricate(:private_team)
      user = soloteam.teammembers.first.user

      expect do
        delete :destroy, params: { id: soloteam.id }
      end.to change { Team.count }.by(0)

      expect(errors.first).to eq 'Access denied'
      expect(user.last_teammember_teams).to be_present
    end
  end
end
