# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'Keycloak user login' do
  include IntegrationHelpers::DefaultHelper

  xit 'logins as new keycloak user' do
    enable_keycloak
    Rails.application.reload_routes!
    pk_secret_base = SecureRandom.base64(32)
    # Mock
    expect(Keycloak::Client)
      .to receive(:url_login_redirect)
      .with(sso_url, 'code')
      .and_return(sso_path(code: 'asd'))
    expect(Keycloak::Client)
      .to receive(:get_token_by_code)
      .with('asd', sso_url)
      .and_return('token')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('sub', 'asd')
      .at_least(:once)
      .and_return('asdQW123-asdQWE')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('preferred_username', 'asd')
      .exactly(4).times
      .and_return('ben')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('given_name', 'asd')
      .at_least(:once)
      .and_return('Ben')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('family_name', 'asd')
      .at_least(:once)
      .and_return('Meier')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('pk_secret_base', 'asd')
      .at_least(:once)
      .and_return(pk_secret_base)
    expect(Keycloak::Client).to receive(:user_signed_in?)
      .and_return(false, true, true, true)

    # login
    expect do
      get root_path
      follow_redirect!
      expect(request.fullpath).to eq('/session/sso')
      follow_redirect!
      expect(request.fullpath).to eq('/session/sso?code=asd')
      follow_redirect!
      user = User.find_by(username: 'ben')
      expect(request.fullpath).to eq(root_path)
      expect(response.body).to match(/Hi Ben! Looking for a password?/)
      expect(user.surname).to eq('Meier')
      expect(user.givenname).to eq('Ben')
    end.to change { User::Human.count }.by(1)
  end

  it 'logs in for real bro' do
    threads = 10
    # break test if not local keycloak
    admin_token = JSON.parse(Keycloak::Client.get_token_by_client_credentials)['access_token']
    users = JSON.parse(Keycloak::Admin.get_users(nil, admin_token))
    users.each do |user|
      Keycloak::Admin.delete_user(user['id'], admin_token)
    end
    threads.times do |i|
      Keycloak::Admin.create_user(
        {
          username: "user#{i}",
          enabled: true,
          totp: false,
          emailVerified: false,
          attributes: { cryptopus_pk_secret_base: ['Gur7Lk4GiUIiyY/OpAzFf+N93QDV5pwDAv+6SrBD+w='] },
          access: {
            view: true,
            mapRoles: true,
            impersonate: false,
            manage: true
          }
        },
        admin_token
      )
    end

    users = JSON.parse(Keycloak::Admin.get_users(nil, admin_token))
    users.each do |user|
      Keycloak::Admin.reset_password(user['id'], { type: 'password', value: 'password', temporary: false }, admin_token)
    end

    results = threads.times.map do |i|
      Thread.new do
        token = Keycloak::Client.get_token("user#{i}", 'password')
        get root_path
        expect(Keycloak::Client)
          .to receive(:url_login_redirect)
          .and_return(sso_path(code: 'asd'))
        expect(Keycloak::Client)
          .to receive(:get_token_by_code)
          .and_return(token)

        follow_redirect!
        follow_redirect!
        follow_redirect!
        expect(request.fullpath).to eq(root_path)
        expect(session[:username]).to eq("user#{i}")
      end
    end
    results.map(&:join)
  end
end
