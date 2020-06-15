# frozen_string_literal: true

require 'rails_helper'

describe Api::TeamsController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:nested_models) { ['folder', 'account'] }

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

    it 'should get a single team if one team_id is given' do
      login_as(:alice)

      team = teams(:team1)

      get :index, params: { 'team_ids': team.id }, xhr: true

      expect(data).to be_a(Array)
      expect(data.count).to eq (1)

      attributes = data.first['attributes']

      included_types = json['included'].map { |e| e['type'] }

      nested_models.each do |model_type|
        expect(included_types).to include(model_type.pluralize)
      end

      expect(attributes['name']).to eq team.name
      expect(attributes['description']).to eq team.description
    end
  end

  context 'PUT update' do
    it 'updates team with valid params structure' do
      set_auth_headers

      team = teams(:team1)

      update_params = {
        data: {
          id: team.id,
          attributes: {
            name: 'Team Bob',
            description: 'yeah, my own team'
          }
        }, id: team.id
      }

      patch :update, params: update_params, xhr: true

      team.reload

      expect(team.name).to eq(update_params[:data][:attributes][:name])
      expect(team.description).to eq(update_params[:data][:attributes][:description])

      expect(response).to have_http_status(200)
    end

    it 'does not update team when user not teammember' do
      request.headers['Authorization-User'] = alice.username
      request.headers['Authorization-Password'] = Base64.encode64('password')

      team = teams(:team2)

      team_params =
        {
          id: team.id,
          team:
            {
              name: 'Team Alice',
              description: 'yeah, i wanna steal that team'
            }
        }
      patch :update, params: team_params, xhr: true

      team.reload

      expect(team.name).to eq('team2')
      expect(team.description).to eq('public')

      expect(response).to have_http_status(403)
    end

    it 'cannot enable private on existing team' do
      set_auth_headers

      team = teams(:team1)

      expect(team).to_not be_private

      update_params = {
        data: {
          id: team.id,
          attributes: {
            private: true
          }
        }, id: team.id
      }

      patch :update, params: update_params, xhr: true

      team.reload

      expect(team).to_not be_private

      expect(response).to have_http_status(200)
    end

    it 'cannot disable private on existing team' do
      set_auth_headers

      team_params = { name: 'foo', private: true }
      team = Team.create(users(:bob), team_params)

      update_params = {
        data: {
          id: team.id,
          attributes: {
            private: false
          }
        }, id: team.id
      }

      patch :update, params: update_params, xhr: true

      team.reload

      expect(team).to be_private

      expect(response).to have_http_status(200)
    end

  end

  context 'POST create' do
    it 'creates new team as user' do
      login_as(:bob)

      team_params = {
        data: {
          attributes: {
            name: 'foo',
            private: false,
            description: 'foo foo'
          }
        }
      }

      expect do
        post :create, params: team_params, xhr: true
      end.to change { Team.count }.by(1)

      team = Team.find_by(name: team_params[:data][:attributes][:name])

      expect(team.description).to eq(team_params[:data][:attributes][:description])
      expect(team.private).to be team_params[:data][:attributes][:private]

      expect(response).to have_http_status(200)
    end

    it 'creates new private team as user' do
      login_as(:bob)

      team_params = {
        data: {
          attributes: {
            name: 'foo',
            private: true,
            description: 'foo foo'
          }
        }
      }

      expect do
        post :create, params: team_params, xhr: true
        expect(response).to have_http_status(200)
      end.to change { Team.count }.by(1)

      team = Team.find_by(name: team_params[:data][:attributes][:name])

      expect(team.description).to eq(team_params[:data][:attributes][:description])
      expect(team.private).to be team_params[:data][:attributes][:private]

      expect(response).to have_http_status(200)
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

    it 'cannot delete team as normal user if not in team' do
      login_as(:bob)

      teammembers(:team1_bob).delete

      expect do
        delete :destroy, params: { id: teams(:team1).id }
      end.to change { Team.count }.by(0)

      expect(response).to have_http_status 403
    end


  end

  private

  def set_auth_headers
    request.headers['Authorization-User'] = bob.username
    request.headers['Authorization-Password'] = Base64.encode64('password')
  end

end
