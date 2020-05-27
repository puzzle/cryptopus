# frozen_string_literal: true

require 'rails_helper'

describe Api::Teams::LastMemberTeamsController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }

  context 'GET last_teammember_teams' do
    it 'returns last teammember teams' do
      login_as(:admin)

      soloteam = Fabricate(:private_team)
      user = soloteam.teammembers.first.user

      get :index, params: { user_id: user.id }

      team_data = data[0]
      team_attributes = team_data['attributes']

      expect(team_data['id'].to_i).to eq soloteam.id
      expect(team_attributes['name']).to eq soloteam.name
      expect(team_attributes['description']).to eq soloteam.description

      expect(response).to have_http_status 200
    end

    it 'returns last teammember teams as conf admin' do
      login_as(:tux)

      soloteam = Fabricate(:private_team)
      user = soloteam.teammembers.first.user

      get :index, params: { user_id: user.id }

      team_data = data[0]
      team_attributes = team_data['attributes']

      expect(team_data['id'].to_i).to eq soloteam.id
      expect(team_attributes['name']).to eq soloteam.name
      expect(team_attributes['description']).to eq soloteam.description

      expect(response).to have_http_status 200
    end

    it 'cannot show last teammember teams if not admin' do
      login_as(:bob)
      soloteam = Fabricate(:private_team)
      user = User.find(soloteam.teammembers.first.user_id)

      get :index, params: { user_id: user.id }

      expect(errors).to include 'Access denied'
      expect(response).to have_http_status 403
    end
  end
end
