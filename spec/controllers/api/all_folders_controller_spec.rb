# frozen_string_literal: true

require 'rails_helper'

describe Api::AllFoldersController do
  include ControllerHelpers

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
end