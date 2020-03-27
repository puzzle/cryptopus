# frozen_string_literal: true

require 'rails_helper'

describe Api::ApiUsersController do
  include ControllerHelpers

  before(:each) do
    login_as(:bob)
  end

  let(:api_user) { users(:bob).api_users.create!(description: 'my sweet api user') }
  let(:foreign_api_user) { users(:alice).api_users.create! }

  context 'GET index' do
    it 'gets api users of user' do
      user = api_user

      get :index, xhr: true

      result_json = json['data']['user/apis'][0]

      expect(result_json['username']).to eq user.username
      expect(result_json['description']).to be_nil
      expect(result_json['valid_for']).to eq user.valid_for
      expect(result_json['id']).to eq user.id
    end

  end

  context 'GET show' do
    it 'shows api user of user' do
      get :show, params: { id: api_user.id }, xhr: true

      result_json = json['data']['user/api']

      expect(result_json['username']).to eq api_user.username
      expect(result_json['description']).to be_nil
      expect(result_json['valid_for']).to eq api_user.valid_for
      expect(result_json['id']).to eq api_user.id
    end
  end

  context 'POST create' do
    it 'creates api user as user' do

      api_params = { description: 'another api user', valid_for: '300' }

      expect do
        post :create, params: { user_api: api_params }
      end.to change { User::Api.count }.by(1)
    end
  end

  context 'PUT update' do
    it 'updates api user of user' do

      update_params = { description: 'my sweetest api user', valid_for: '43200' }

      put :update, params: { id: api_user.id, user_api: update_params }, xhr: true

      api_user.reload

      expect(api_user.valid_for).to eq 43200
      expect(api_user.description).to eq 'my sweetest api user'
    end
  end

  context 'DELETE destroy' do
    it 'deletes api user of user' do
      user = api_user
      expect do
        delete :destroy, params: { id: user.id }
      end.to change { User::Api.count }.by(-1)
    end
  end
end
