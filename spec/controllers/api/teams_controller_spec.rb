# frozen_string_literal: true

require 'rails_helper'

describe Api::TeamsController do
  include ControllerHelpers

  let!(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:team1) { teams(:team1) }
  let(:team2) { teams(:team2) }
  let!(:team3) { Fabricate(:non_private_team) }
  let!(:team4) { Fabricate(:non_private_team) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let!(:team3_user) { team3.teammembers.first.user }

  context 'GET index' do
    it 'should get team for search term' do
      login_as(:bob)
      get :index, params: { 'q': '2' }, xhr: true

      expect(data.size).to be(1)
      expect(included.size).to be(2)

      team = data.first
      folder = included.first
      account = included.second

      expect(team['attributes']['name']).to eq team2.name
      expect(team['id']).to eq team2.id.to_s

      folder2 = folders(:folder2)
      account2 = accounts(:account2)

      expect(folder['attributes']['name']).to eq folder2.name
      expect(folder['id']).to eq folder2.id.to_s

      expect(account['attributes']['accountname']).to eq account2.accountname
      expect(account['id']).to eq account2.id.to_s
    end

    it 'should get all teams for no query' do
      login_as(:bob)

      get :index, params: { 'q': '' }, xhr: true

      expect(data.size).to eq(2)

      result_json = data.first

      expect(result_json['attributes']['name']).to eq team1.name
      expect(result_json['id']).to eq team1.id.to_s

      result_json = data.second

      expect(result_json['attributes']['name']).to eq team2.name
      expect(result_json['id']).to eq team2.id.to_s
    end

    it 'should get a single team if one team_id is given' do
      login_as(:bob)

      get :index, params: { 'team_id': team1.id }, xhr: true

      expect(data).not_to be(Array)
      expect(response.status).to be(200)

      attributes = data['attributes']

      included_types = json['included'].map { |e| e['type'] }

      expect(included_types).to include('folder'.pluralize)
      expect(included_types).to include('account'.pluralize)

      expect(attributes['name']).to eq team1.name
      expect(attributes['description']).to eq team1.description

      expect(attributes['name']).not_to eq team3.name
      expect(attributes['description']).not_to eq team3.description
    end

    it 'should not get team if not member' do
      login_as(:alice)

      expect do
        get :index, params: { 'team_id': team2.id }, xhr: true
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should get teams, folders and accounts for query' do
      login_as(:bob)

      folder1 = folders(:folder1)
      folder2 = folders(:folder2)

      account1 = accounts(:account1)
      account2 = accounts(:account2)

      get :index, params: { 'q': 'account2' }, xhr: true

      expect(data.count).to eq(1)
      expect(response.status).to be(200)

      attributes_first_team = data.first['attributes']

      expect(attributes_first_team['name']).to eq team2.name
      expect(attributes_first_team['description']).to eq team2.description

      folders = included.select { |element| element['type'] == 'folder'.pluralize }
      accounts = included.select { |element| element['type'] == 'account'.pluralize }

      expect(folders.first['attributes']['name']).to eq(folder2.name)
      expect(folders).not_to include(folder1.name)

      expect(accounts.first['attributes']['accountname']).to eq(account2.accountname)
      expect(accounts).not_to include(account1.accountname)
    end

    it 'should get team for specific team name' do
      add_bob_to_team(team3, team3_user)
      login_as(:bob)

      get :index, params: { 'q': team3.name }, xhr: true

      expect(data.count).to eq(1)
      expect(response.status).to be(200)

      attributes_team = data.first['attributes']

      expect(data.first['id'].to_i).to eq team3.id
      expect(attributes_team['name']).to eq team3.name
      expect(attributes_team['description']).to eq team3.description
      expect(attributes_team['private']).to eq team3.private
    end

    it 'should get folder for specific folder name' do
      add_bob_to_team(team3, team3_user)
      login_as(:bob)

      folder = team3.folders.first

      get :index, params: { 'q': folder.name }, xhr: true

      expect(data.count).to eq(1)
      expect(response.status).to be(200)

      relationships_folder_team = data.first['relationships']['folders']['data'].first

      expect(relationships_folder_team['id'].to_i).to eq folder.id
      expect(relationships_folder_team['type']).to eq 'folder'.pluralize
    end

    it 'should get account for specific account name' do
      add_bob_to_team(team3, team3_user)
      login_as(:bob)

      folder = team3.folders.first
      account = folder.accounts.first

      get :index, params: { 'q': account.accountname }, xhr: true

      expect(data.count).to eq(1)
      expect(response.status).to be(200)

      included_account = included.second

      expect(included_account['id'].to_i).to eq account.id
      expect(included_account['attributes']['accountname']).to eq account.accountname
      expect(included_account['attributes']['description']).to eq account.description
    end

  end

  context 'PUT update' do
    it 'updates team with valid params structure' do
      set_auth_headers

      update_params = {
        data: {
          id: team1.id,
          attributes: {
            name: 'Team Bob',
            description: 'yeah, my own team'
          }
        }, id: team1.id
      }

      patch :update, params: update_params, xhr: true

      team1.reload

      expect(team1.name).to eq(update_params[:data][:attributes][:name])
      expect(team1.description).to eq(update_params[:data][:attributes][:description])

      expect(response).to have_http_status(200)
    end

    it 'does not update team when user not teammember' do
      request.headers['Authorization-User'] = alice.username
      request.headers['Authorization-Password'] = Base64.encode64('password')

      team_params =
        {
          id: team2.id,
          team:
            {
              name: 'Team Alice',
              description: 'yeah, i wanna steal that team'
            }
        }
      patch :update, params: team_params, xhr: true

      team2.reload

      expect(team2.name).to eq('team2')
      expect(team2.description).to eq('public')

      expect(response).to have_http_status(403)
    end

    it 'cannot enable private on existing team' do
      set_auth_headers

      expect(team1).to_not be_private

      update_params = {
        data: {
          id: team1.id,
          attributes: {
            private: true
          }
        }, id: team1.id
      }

      patch :update, params: update_params, xhr: true

      team1.reload

      expect(team1).to_not be_private

      expect(response).to have_http_status(200)
    end

    it 'cannot disable private on existing team' do
      set_auth_headers

      team_params = { name: 'foo', private: true }
      new_team = Team.create(users(:bob), team_params)

      update_params = {
        data: {
          id: new_team.id,
          attributes: {
            private: false
          }
        }, id: new_team.id
      }

      patch :update, params: update_params, xhr: true

      new_team.reload

      expect(new_team).to be_private

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

  def add_bob_to_team(team, user)
    decrypted_team_password = team.decrypt_team_password(user, user.decrypt_private_key('password'))
    team.add_user(bob, decrypted_team_password)
  end

  def set_auth_headers
    request.headers['Authorization-User'] = bob.username
    request.headers['Authorization-Password'] = Base64.encode64('password')
  end

end
