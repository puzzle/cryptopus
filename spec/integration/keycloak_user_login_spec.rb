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
      .with(sso_url, 'code')
      .and_return(sso_path(code: 'asd'))
    expect(Keycloak::Client)
      .to receive(:get_token_by_code)
      .with('asd', sso_url)
      .and_return('token')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('sub')
      .at_least(:once)
      .and_return('asdQW123-asdQWE')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('preferred_username')
      .at_least(:once)
      .and_return('ben')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('given_name')
      .at_least(:once)
      .and_return('Ben')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('family_name')
      .at_least(:once)
      .and_return('Meier')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('pk_secret_base')
      .at_least(:once)
      .and_return(pk_secret_base)
    expect(Keycloak::Client).to receive(:user_signed_in?)
      .and_return(false, true, true)

    # login
    expect do
      get search_path
      follow_redirect!
      expect(request.fullpath).to eq('/session/sso')
      follow_redirect!
      expect(request.fullpath).to eq('/session/sso?code=asd')
      follow_redirect!
      user = User.find_by(username: 'ben')
      expect(request.fullpath).to eq(search_path)
      expect(response.body).to match(/Hi  Ben! Want to recover a password?/)
      expect(user.surname).to eq('Meier')
      expect(user.givenname).to eq('Ben')
    end.to change { User::Human.count }.by(1)
  end
end
