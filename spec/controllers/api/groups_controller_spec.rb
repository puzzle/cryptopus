# frozen_string_literal: true

require 'rails_helper'

describe Api::GroupsController do
  include ControllerHelpers

  context 'GET index' do
    it 'returns matching groups' do

      login_as(:alice)

      get :index, params: { 'q': 'group' }, xhr: true

      group_json = data.first
      attributes = group_json['attributes']

      group = groups(:group1)

      expect(attributes['name']).to eq group.name
      expect(group_json['id']).to eq group.id.to_s

    end

    it 'returns all groups if empty query param given' do

      login_as(:alice)

      get :index, params: { 'q': '' }, xhr: true

      group_json = data.first
      attributes = group_json['attributes']

      group = groups(:group1)

      expect(attributes['name']).to eq group.name
      expect(group_json['id']).to eq group.id.to_s
    end

    it 'returns all groups if no query param given' do

      login_as(:alice)

      get :index, xhr: true

      group_json = data.first
      attributes = group_json['attributes']

      group = groups(:group1)

      expect(attributes['name']).to eq group.name
      expect(group_json['id']).to eq group.id.to_s
    end
  end
end
