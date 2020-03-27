# frozen_string_literal: true

require 'rails_helper'

describe Api::Team::GroupsController do
  include ControllerHelpers

  context 'GET index' do
    it 'lists all groups of a given team' do
      login_as(:bob)
      team = teams(:team1)

      get :index, params: { team_id: team }, xhr: true

      groups = json['data']['groups']

      expect(groups.first['name']).to eq 'group1'
    end
  end
end
