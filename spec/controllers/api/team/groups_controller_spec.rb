# frozen_string_literal: true

require 'rails_helper'

describe Api::Teams::GroupsController do
  include ControllerHelpers

  context 'GET index' do
    it 'lists all groups of a given team' do
      login_as(:bob)
      team = teams(:team1)

      get :index, params: { team_id: team }, xhr: true

      attributes = data.first['attributes']

      expect(attributes['name']).to eq 'group1'
    end

    it 'does not list groups without team membership' do
      login_as(:alice)
      team = teams(:team2)

      get :index, params: { team_id: team }, xhr: true

      expect(response).to have_http_status(403)
    end
  end
end
