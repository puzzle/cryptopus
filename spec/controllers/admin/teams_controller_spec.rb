# frozen_string_literal: true

require 'rails_helper'

describe Admin::TeamsController do
  include ControllerHelpers

  context 'GET index' do
    it 'cant access admin teams as user' do
      login_as(:bob)

      get :index

      teamlist = assigns(:teams)

      expect(response).to redirect_to teams_path
      expect(teamlist).to be_nil
    end

    it 'lists teams as conf admin' do
      login_as(:tux)

      get :index

      teamlist = assigns(:teams)

      expect(teamlist.size).to eq 2
      expect(teamlist.any? { |t| t.name == 'team1' }).to be true
      expect(teamlist.any? { |t| t.name == 'team2' }).to be true
    end

    it 'lists teams as admin' do
      login_as(:admin)

      get :index

      teamlist = assigns(:teams)

      expect(teamlist.size).to eq 2
      expect(teamlist.any? { |t| t.name == 'team1' }).to be true
      expect(teamlist.any? { |t| t.name == 'team2' }).to be true
    end
  end
end
