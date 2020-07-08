# frozen_string_literal: true

require 'rails_helper'

describe Api::FoldersController do
  include ControllerHelpers

  let(:alice) { users(:alice) }

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

  context 'PUT update' do
    it 'updates folder name and description with valid params structure' do
      login_as(:alice)
      folder = folders(:folder1)
      team = teams(:team1)

      update_params = { attributes: { name: 'new_name', description: 'new_description' } }
      put :update, params: { team_id: team, id: folder, data: update_params }

      folder.reload

      expect(folder.name).to eq 'new_name'
      expect(folder.description).to eq 'new_description'

    end

    it 'does not update folder when user not teammember' do
      request.headers['Authorization-User'] = alice.username
      request.headers['Authorization-Password'] = Base64.encode64('password')

      folder = folders(:folder2)
      team = teams(:team2)

      folder_params = {
        id: folder.id,
        team_id: team.id,
        folder:
        {
          name: 'Folder Alice',
          description: 'yeah, i wanna steal that folder'
        }
      }
      patch :update, params: folder_params, xhr: true

      folder.reload

      expect(folder.name).not_to eq('team2')

      expect(response).to have_http_status(403)
    end

  end

  context 'POST create' do
    it 'creates folder name and description' do
      login_as(:alice)
      team = teams(:team1)

      new_folder_params = {
        team_id: team.id,
        data: {
          attributes: {
            name: 'Folder Alice',
            description: 'yeah'
          },
          relationships: {
            team: {
              data: {
                id: team.id,
                type: 'teams'
              }
            }
          }
        }
      }
      expect do
        post :create, params: new_folder_params, xhr: true
      end.to change { Folder.count }.by(1)

      expect(response).to have_http_status(201)
      expect(data['attributes']['name']).to eq 'Folder Alice'
      expect(data['attributes']['description']).to eq 'yeah'
    end

    it 'doesnt create folder name and description if not teammember' do
      login_as(:alice)
      team = teams(:team2)

      new_folder_params = {
        team_id: team.id,
        data: {
          attributes: {
            name: 'Folder Alice',
            description: 'yeah'
          },
          relationships: {
            team: {
              data: {
                id: team.id,
                type: 'teams'
              }
            }
          }
        }
      }
      expect do
        post :create, params: new_folder_params, xhr: true
      end.to change { Folder.count }.by(0)

      expect(response).to have_http_status(403)
      expect(data).to eq nil
    end
  end

end
