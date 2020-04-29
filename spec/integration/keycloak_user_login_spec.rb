# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'Keycloak user login' do
  include IntegrationHelpers::DefaultHelper

  before(:each) do
    enable_keycloak
  end

  it 'logins as new keycloak user' do
    # Mock
    expect(Keycloak::Client).to receive(:url_login_redirect)
      .with(session_login_keycloak_url, 'code')
      .and_return(session_login_keycloak_path)
    expect(Keycloak::Client).to receive(:get_token_by_code)
      .and_return('asdasda')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('sub')
      .and_return('asdQW123-asdQWE')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('preferred_username')
      .and_return('ben')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('given_name')
      .and_return('Ben')
      .twice
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('family_name')
      .and_return('Meier')
      .twice
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('pk_secret_base').at_least(:once)
      .and_return(SecureRandom.base64(32))
      .thrice
    expect(Keycloak::Client).to receive(:user_signed_in?)
      .and_return(false)
      .once
    expect(Keycloak::Client).to receive(:user_signed_in?)
      .and_return(true)
      .at_least(:once)
    expect(Keycloak::Admin).to receive(:update_user)
      .and_return(true)

    # login
    expect do
      get search_path
      follow_redirect!
      Keycloak::Client.user_signed_in?
      follow_redirect!
      user = User.find_by(username: 'ben')
      expect(request.fullpath).to eq(search_path)
      expect(response.body).to match(/Hi  Ben! Want to recover a password?/)
      expect(user.surname).to eq('Meier')
      expect(user.givenname).to eq('Ben')
    end.to change { User::Human.count }.by(1)
  end

  context 'fallback' do
    it 'login root via fallback' do
      get session_fallback_path
      login_as('root')
      expect(request.fullpath).to eq(search_path)
      expect(response.body).to match(/Hi  Root! Want to recover a password?/)
    end
  end
end
