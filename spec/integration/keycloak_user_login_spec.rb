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

  it 'two logins', :threadsafety => true do
    alice = login(:alice)
    bob = login(:bob)
    login_as(:bob)

    alice.check_user('Alice')
    bob.check_user('Bob')

  end

  private

  module CustomDsl
    def check_user(expected_givenname)
      get api_env_settings_path
      require 'pry'; binding.pry

      givenname = JSON.parse(body)['current_user']['id']

      expect(givenname).to be expected_givenname
    end
  end

  def login(user)
    open_session do |sess|
      sess.extend(CustomDsl)
      u = users(user)
      sess.https!
      sess.post "/session", params: { username: u.username, password: u.password }
      require 'pry'; binding.pry
      sess.follow_redirect!
      assert_equal '/session', sess.path
      sess.https!(false)
    end
  end

end
