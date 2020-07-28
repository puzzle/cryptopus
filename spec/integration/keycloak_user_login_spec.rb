# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'Keycloak user login' do
  include IntegrationHelpers::DefaultHelper

  it 'logins as new keycloak user' do
    enable_keycloak
    Rails.application.reload_routes!
    pk_secret_base = SecureRandom.base64(32)
    # Mock
    expect(Keycloak::Client)
      .to receive(:url_login_redirect)
      .at_least(:once)
      .with(sso_url, 'code')
      .and_return(sso_path(code: 'asd'))
    expect(Keycloak::Client)
      .to receive(:get_token_by_code)
      .at_least(:once)
      .with('asd', sso_url)
      .and_return(token)
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('sub', 'token')
      .at_least(:once)
      .and_return('asdQW123-asdQWE')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('preferred_username', 'token')
      .exactly(4).times
      .and_return('ben')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('given_name', 'token')
      .at_least(:once)
      .and_return('Ben')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('family_name', 'token')
      .at_least(:once)
      .and_return('Meier')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('pk_secret_base', 'token')
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
      follow_redirect!
      user = User.find_by(username: 'ben')
      expect(request.fullpath).to eq(root_path)
      expect(user.surname).to eq('Meier')
      expect(user.givenname).to eq('Ben')
      expect(session[:username]).to eq('ben')
    end.to change { User::Human.count }.by(1)
  end

  private

  def token
    { access_token: 'token',
      expires_in: 300,
      refresh_expires_in: 1800,
      refresh_token: 'refresh_token' }.to_json
  end
end
