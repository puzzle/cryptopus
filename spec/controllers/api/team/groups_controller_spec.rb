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

    it 'cannot list all groups of a given team as conf admin' do
      login_as(:tux)
      team = teams(:team1)

      get :index, params: { team_id: team }, xhr: true

      expect(json['data']).to eq nil
    end

    it 'lists all groups of a given team as admin' do
      login_as(:admin)
      team = teams(:team1)

      get :index, params: { team_id: team }, xhr: true

      groups = json['data']['groups']

      expect(groups.first['name']).to eq 'group1'
    end
  end
end
