# frozen_string_literal: true

require 'rails_helper'

describe Session::LocalController do
  include ControllerHelpers

  context 'GET new' do
    it 'can be accesed from private ip' do
      expect_any_instance_of(Authentication::SourceIpChecker)
        .to receive(:private_ip?)
        .and_return(true)

      get :new

      expect(response).to have_http_status 200
    end

    it 'can\'t be accesed from non private ip' do
      expect_any_instance_of(Authentication::SourceIpChecker)
        .to receive(:private_ip?)
        .and_return(false)

      get :new

      expect(response).to have_http_status(401)
      expect(response.body).to match(/You are not allowed to access this Page from your country/)
    end
  end

  context 'POST create' do
    it 'logs-in' do
      expect_any_instance_of(Authentication::SourceIpChecker)
        .to receive(:private_ip?)
        .and_return(true)
      post :create, params: { password: 'password', username: 'root' }

      expect(response).to redirect_to root_path
    end

    it 'cannot login with wrong password' do
      expect_any_instance_of(Authentication::SourceIpChecker)
        .to receive(:private_ip?)
        .and_return(true)
      post :create, params: { password: 'wrong_password', username: 'root' }

      expect(flash[:error]).to match(/Authentication failed/)
    end

    it 'cannot login with not root username with keycloak enabled' do
      enable_keycloak
      expect_any_instance_of(Authentication::SourceIpChecker)
        .to receive(:private_ip?)
        .and_return(true)
      post :create, params: { password: 'password', username: 'bob' }

      expect(flash[:error]).to match(/Authentication failed/)
    end

    it 'updates last login at if user logs in' do
      expect_any_instance_of(Authentication::SourceIpChecker)
        .to receive(:private_ip?)
        .and_return(true)
      time = Time.zone.now
      expect_any_instance_of(ActiveSupport::TimeZone).to receive(:now).and_return(time)

      post :create, params: { password: 'password', username: 'root' }

      users(:root).reload
      expect(users(:root).last_login_at.to_s).to eq time.to_s
    end
  end
end
