# frozen_string_literal: true

require 'rails_helper'

describe WizardController do
  include ControllerHelpers

  context 'POST apply' do
    it 'displays error if password fields empty' do
      User::Human.delete_all
      post :apply, params: { password: '', password_repeat: 'password' }
      expect(flash[:error]).to match(/Please provide an initial password/)
    end

    it 'displays error if passwords do not match' do
      User::Human.delete_all
      post :apply, params: { password: 'password', password_repeat: 'other_password' }
      expect(flash[:error]).to match(/Passwords do not match/)
    end

    it 'creates initial setup and redirects to user admin page' do
      User::Human.delete_all
      post :apply, params: { password: 'password', password_repeat: 'password' }
      expect(response).to redirect_to(admin_users_path)
      expect(User.find_by(provider_uid: '0')).to be
    end

    context 'GET index' do
      it 'cannot access wizard if already set up' do
        post :apply, params: { password: 'password', password_repeat: 'password' }
        expect(response).to redirect_to(session_new_path)

        get :index
        expect(response).to redirect_to(session_new_path)
      end

      it 'cannot access wizard as logged in user if already set up' do
        login_as('bob')
        post :apply, params: { password: 'password', password_repeat: 'password' }
        expect(response).to redirect_to(session_new_path)

        get :index
        expect(response).to redirect_to(session_new_path)
      end
    end
  end
end
