# frozen_string_literal: true

require 'rails_helper'

describe Api::GroupsController do
  include ControllerHelpers

  context 'GET index' do
    it 'returns matching groups' do

      login_as(:alice)

      get :index, params: { 'q': 'group' }, xhr: true

      result_json = JSON.parse(response.body)['data']['groups'][0]

      group = groups(:group1)

      expect(result_json['name']).to eq group.name
      expect(result_json['id']).to eq group.id

    end

    it 'returns matching groups as admin' do

      login_as(:admin)

      get :index, params: { 'q': 'group' }, xhr: true

      result_json = JSON.parse(response.body)['data']['groups'][0]

      group = groups(:group1)

      expect(result_json['name']).to eq group.name
      expect(result_json['id']).to eq group.id

    end

    it 'returns all groups if empty query param given' do

      login_as(:alice)

      get :index, params: { 'q': '' }, xhr: true

      result_json = JSON.parse(response.body)['data']['groups'][0]

      group = groups(:group1)

      expect(result_json['name']).to eq group.name
      expect(result_json['id']).to eq group.id

    end

    it 'returns all groups if empty query param given as admin' do

      login_as(:admin)

      get :index, params: { 'q': '' }, xhr: true

      result_json = JSON.parse(response.body)['data']['groups'][0]

      group = groups(:group1)

      expect(result_json['name']).to eq group.name
      expect(result_json['id']).to eq group.id

    end

    it 'returns all groups if no query param given' do

      login_as(:alice)

      get :index, xhr: true

      result_json = JSON.parse(response.body)['data']['groups'][0]

      group = groups(:group1)

      expect(result_json['name']).to eq group.name
      expect(result_json['id']).to eq group.id
    end

    it 'returns all groups if no query param given as admin' do

      login_as(:admin)

      get :index, xhr: true

      result_json = JSON.parse(response.body)['data']['groups'][0]

      group = groups(:group1)

      expect(result_json['name']).to eq group.name
      expect(result_json['id']).to eq group.id
    end
  end
end
