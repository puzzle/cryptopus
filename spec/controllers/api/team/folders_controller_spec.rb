# frozen_string_literal: true

require 'rails_helper'

describe Api::Teams::FoldersController do
  include ControllerHelpers

  context 'GET index' do
    it 'lists all folders of a given team' do
      login_as(:bob)
      team = teams(:team1)

      get :index, params: { team_id: team }, xhr: true

      attributes = data.first['attributes']

      expect(attributes['name']).to eq 'folder1'
    end

    it 'does not list folders without team membership' do
      login_as(:alice)
      team = teams(:team2)

      get :index, params: { team_id: team }, xhr: true

      expect(response).to have_http_status(403)
    end
  end
end
