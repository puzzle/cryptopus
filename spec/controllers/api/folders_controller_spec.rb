# frozen_string_literal: true

require 'rails_helper'

describe Api::FoldersController do
  include ControllerHelpers

  let(:alice) { users(:alice) }

  context 'GET index' do
    it 'returns matching folders' do

      login_as(:alice)

      get :index, params: { 'q': 'folder' }, xhr: true

      folder_json = data.first
      attributes = folder_json['attributes']

      folder = folders(:folder1)

      expect(attributes['name']).to eq folder.name
      expect(folder_json['id']).to eq folder.id.to_s

    end

    it 'returns all folders if empty query param given' do

      login_as(:alice)

      get :index, params: { 'q': '' }, xhr: true

      folder_json = data.first
      attributes = folder_json['attributes']

      folder = folders(:folder1)

      expect(attributes['name']).to eq folder.name
      expect(folder_json['id']).to eq folder.id.to_s
    end

    it 'returns all folders if no query param given' do

      login_as(:alice)

      get :index, xhr: true

      folder_json = data.first
      attributes = folder_json['attributes']

      folder = folders(:folder1)

      expect(attributes['name']).to eq folder.name
      expect(folder_json['id']).to eq folder.id.to_s
    end
  end

  context 'PUT update' do
    it 'updates folder name and description with valid params structure' do
      login_as(:alice)
      folder = folders(:folder1)
      team = teams(:team1)

      update_params = { name: 'new_name', description: 'new_description' }
      put :update, params: {team_id: team, id: folder, folder: update_params }

      folder.reload

      expect(folder.name).to eq 'new_name'
      expect(folder.description).to eq 'new_description'

    end

    it 'does not update folder when user not teammember' do
      request.headers['Authorization-User'] = alice.username
      request.headers['Authorization-Password'] = Base64.encode64('password')

      folder = folders(:folder2)

      folder_params =
          {
              id: folder.id,
              folder:
                  {
                      name: 'Folder Alice',
                      description: 'yeah, i wanna steal that folder'
                  }
          }
      patch :update, params: folder_params, xhr: true

      folder.reload

      expect(folder.name).to eq('team2')

      expect(response).to have_http_status(403)
    end

  end

  context 'POST create' do
    it 'creates folder name and description' do
      login_as(:alice)
      team = teams(:team1)

      new_folder_params = {
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

      post :create, params: new_folder_params , xhr: true

      folder.reload

      expect(folder.name).to eq 'Folder Alice'
      expect(folder.description).to eq 'yeah'
    end
  end

end
