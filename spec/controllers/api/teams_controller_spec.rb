# frozen_string_literal: true

require 'spec_helper'

describe Api::TeamsController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
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

      get :index, params: { q: 'non' }, xhr: true

      expect(data.size).to be(0)
      expect(included).to be(nil)
    end

    it 'raises invalid argument error if query param blank' do
      login_as(:bob)

      get :index, params: { q: '' }, xhr: true

      expect(response).to have_http_status 400
      expect(errors).to eq(['flashes.api.errors.bad_request'])
    end

    it 'returns all teams and its folders if no query nor id is given' do
      login_as(:bob)

      get :index, xhr: true

      expect(data.size).to be(2)
      expect(included.size).to be(4)

      data.each do |team|
        expect(team['type']).to eq('teams')
      end

      included_folders = included.select { |e| e['type'] == 'folders' }
      expect(included_folders.size).to be(4)
    end

    it 'raises error if team_id doesnt exist' do
      login_as(:alice)

      inexistent_id = 11111111

      get :index, params: { team_id: inexistent_id }, xhr: true

      expect(response).to have_http_status 404
      expect(errors).to eq(['flashes.api.errors.record_not_found'])
    end

    it 'returns a single team if one team_id is given' do
      login_as(:bob)

      get :index, params: { team_id: team1.id }, xhr: true

      expect(response.status).to be(200)

      attributes = data.first['attributes']

      included_types = json['included'].map { |e| e['type'] }

      expect(included_types).to include('folders')
      expect(included_types).to include('encryptable_credentials')

      expect(attributes['name']).to eq team1.name
      expect(attributes['description']).to eq team1.description

      expect(attributes['name']).not_to eq team3.name
      expect(attributes['description']).not_to eq team3.description

      folder_relationships_length = data.first['relationships']['folders']['data'].size

      expect(included.size).to be(4)
      expect(folder_relationships_length).to be(3)
    end

    it 'returns bobs favourite teams' do
      login_as(:bob)

      get :index, params: { favourite: true }, xhr: true

      expect(response.status).to be(200)

      expect(data.size).to be(1)
      attributes = data.first['attributes']

      included_types = json['included'].map { |e| e['type'] }

      expect(included_types).to include('folders')
      expect(included_types).to include('encryptable_credentials')

      expect(attributes['name']).to eq team1.name
      expect(attributes['description']).to eq team1.description

      folder_relationships_length = data.first['relationships']['folders']['data'].size

      expect(included.size).to be(4)
      expect(folder_relationships_length).to be(3)

    end

    it 'doesnt return team if not member' do
      login_as(:alice)

      get :index, params: { team_id: team2.id }, xhr: true

      expect(response.status).to be(403)
      expect(errors).to eq(['flashes.admin.admin.no_access'])
      expect(data).to be(nil)
      expect(included).to be(nil)
    end

    it 'doesnt return team by query if not team member' do
      login_as(:alice)

      get :index, params: { q: team2.name }, xhr: true

      expect(response.status).to be(200)

      expect(data).to eq([])
      expect(included).to be(nil)

    end

    it 'returns teams, folders and encryptables for query' do
      login_as(:bob)

      folder1 = folders(:folder1)
      folder2 = folders(:folder2)

      credentials1 = encryptables(:credentials1)
      credentials2 = encryptables(:credentials2)

      get :index, params: { q: 'twitter' }, xhr: true

      expect(data.count).to eq(1)
      expect(response.status).to be(200)

      attributes_first_team = data.first['attributes']

      expect(attributes_first_team['name']).to eq team2.name
      expect(attributes_first_team['description']).to eq team2.description

      folders = included.select { |element| element['type'] == 'folders' }
      encryptables = included.select { |element| element['type'] == 'encryptable_credentials' }

      expect(folders.first['attributes']['name']).to eq(folder2.name)
      expect(folders).not_to include(folder1.name)

      expect(encryptables.first['attributes']['name']).to eq(credentials2.name)
      expect(encryptables).not_to include(credentials1.name)
      folder_relationships_length = data.first['relationships']['folders']['data'].size

      expect(included.size).to be(2)
      expect(folder_relationships_length).to be(1)
    end

    it 'filters by team name' do
      add_bob_to_team(team3, team3_user)
      login_as(:bob)

      get :index, params: { q: team3.name }, xhr: true

      expect(data.count).to eq(1)
      expect(response.status).to be(200)

      attributes_team = data.first['attributes']
      team3_attributes = team3.attributes
      team3_attributes['favourised'] = false
      team3_attributes['deletable'] = false
      expect(team3_attributes).to include(attributes_team)
      folder_relationships_length = data.first['relationships']['folders']['data'].size

      expect(included.size).to be(2)
      expect(folder_relationships_length).to be(1)
    end

    it 'filters by folder name' do
      add_bob_to_team(team3, team3_user)
      login_as(:bob)

      folder = team3.folders.first

      get :index, params: { q: folder.name }, xhr: true

      expect(data.count).to eq(1)
      expect(response.status).to be(200)

      relationships_folder_team = data.first['relationships']['folders']['data'].first

      expect(relationships_folder_team['id'].to_i).to eq folder.id
      expect(relationships_folder_team['type']).to eq 'folders'
      folder_relationships_length = data.first['relationships']['folders']['data'].size

      expect(included.size).to be(2)
      expect(folder_relationships_length).to be(1)
    end

    it 'filters by encryptable name' do
      add_bob_to_team(team3, team3_user)
      login_as(:bob)

      folder = team3.folders.first
      credential = folder.encryptables.first

      get :index, params: { q: credential.name }, xhr: true

      expect(data.count).to eq(1)
      expect(response.status).to be(200)

      included_encryptable = included.second

      expect(included_encryptable['id'].to_i).to eq credential.id
      expect(included_encryptable['attributes']['name']).to eq credential.name
      expect(included_encryptable['attributes']['description']).to eq credential.description
    end

    it 'filters by encryptable description' do
      add_bob_to_team(team3, team3_user)
      login_as(:bob)

      credentials1 = encryptables(:credentials1)

      get :index, params: { q: credentials1.description }, xhr: true

      expect(data.count).to eq(1)
      expect(response.status).to be(200)

      included_encryptable = included.second

      expect(included_encryptable['id'].to_i).to eq credentials1.id
      expect(included_encryptable['attributes']['name']).to eq credentials1.name
      expect(included_encryptable['attributes']['description']).to eq credentials1.description
    end

    context 'with only_teammember_user_id param' do
      let(:soloteam) { Fabricate(:private_team) }
      let(:only_teammember_user) { soloteam.teammembers.first.user }

      context 'as admin' do
        before { login_as(:admin) }

        it 'returns soloteam' do
          get :index, params: { only_teammember_user_id: only_teammember_user.id }

          team_data = data[0]
          team_attributes = team_data['attributes']

          expect(team_data['id'].to_i).to eq(soloteam.id)
          expect(team_attributes['name']).to eq(soloteam.name)
          expect(team_attributes['description']).to eq(soloteam.description)

          expect(response).to have_http_status(200)
        end
      end

      context 'as conf_admin' do
        before { login_as(:tux) }

        it 'returns soloteam' do
          get :index, params: { only_teammember_user_id: only_teammember_user.id }

          team_data = data[0]
          team_attributes = team_data['attributes']

          expect(team_data['id'].to_i).to eq(soloteam.id)
          expect(team_attributes['name']).to eq(soloteam.name)
          expect(team_attributes['description']).to eq(soloteam.description)

          expect(response).to have_http_status(200)
        end
      end

      context 'as user' do
        before { login_as(:bob) }

        it 'is not unauthorized' do
          get :index, params: { only_teammember_user_id: only_teammember_user.id }

          expect(response).to have_http_status(403)
        end
      end
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

      expect(response).to have_http_status(201)
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
        expect(response).to have_http_status(201)
      end.to change { Team.count }.by(1)

      team = Team.find_by(name: team_params[:data][:attributes][:name])

      expect(team.description).to eq(team_params[:data][:attributes][:description])
      expect(team.private).to be team_params[:data][:attributes][:private]

      expect(response).to have_http_status(201)
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

      expect(errors).to eq(['flashes.admin.admin.no_access'])
      expect(response).to have_http_status 403
      expect(user.only_teammember_teams).to be_present
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
