# frozen_string_literal: true

require 'rails_helper'

describe Admin::RecryptrequestsController do
  include ControllerHelpers

  before(:each) do
    request.env['HTTP_REFERER'] = 'where_i_came_from'
  end

  context 'POST resetpassword' do
    it 'shows error message if recrypt_team_password raises error' do
      expect(CryptUtils).to receive(:decrypt_rsa).and_raise('test')

      login_as(:admin)
      bob = users(:bob)

      post :resetpassword, params: { new_password: 'test', user_id: bob.id }

      expect(flash[:error]).to match(/test/)
    end

    it 'resets bobs password and removes bobs private teams as root' do
      login_as(:admin)
      bob = users(:bob)
      bob_only_team_id = teams(:team2).id

      post :resetpassword, params: { new_password: 'test', user_id: bob.id }

      bob.reload

      expect(Team.exists?(bob_only_team_id)).to eq false
      expect(Authentication::UserAuthenticator.init(username: bob.username, password: 'test')
                                         .authenticate!).to eq(true)
      expect(response).to redirect_to 'where_i_came_from'
    end

    it 'does not reset password if blank password' do
      login_as(:admin)
      bob = users(:bob)
      bob_password = bob.password

      post :resetpassword, params: { user_id: bob.id }

      bob.reload

      expect(bob.password).to eq bob_password
      expect(response).to redirect_to 'where_i_came_from'
      expect(flash[:notice]).to match(/The password must not be blank/)
    end

    it 'does not reset ldap users password' do
      login_as(:admin)
      bob = users(:bob)
      bob.update!(auth: 'ldap')
      bob_password = bob.password

      post :resetpassword, params: { new_password: 'test', user_id: bob.id }

      bob.reload

      expect(bob.password).to eq bob_password
      expect(response).to redirect_to teams_path
    end

    it 'cant reset password as normal user' do
      login_as(:bob)
      alice = users(:alice)
      alice_password = alice.password

      post :resetpassword, params: { new_password: 'test', user_id: alice.id }

      alice.reload

      expect(alice.password).to eq alice_password
    end
  end

  describe 'GET index' do
    render_views

    it 'cant access index by user' do
      login_as(:bob)

      get :index

      expect(response).to redirect_to teams_path
    end

    it 'cant access index by conf admin' do
      login_as(:tux)

      get :index

      expect(response).to redirect_to teams_path
    end

    it 'can access index by root' do
      login_as(:admin)

      get :index

      expect(response.body).to match(/<h1>Re-encryption requests/)
    end

    it 'shows no error when recryptrequests are present' do

      login_as(:admin)
      bob = users(:bob)
      rec = Recryptrequest.new
      rec.user_id = bob.id
      rec.save

      get :index

      expect(response.body).to match(/<h1>Re-encryption requests/)

    end

  end
end
