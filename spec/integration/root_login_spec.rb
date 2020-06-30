# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'Root login' do
  include IntegrationHelpers::DefaultHelper

  xit 'lets root login via local ip' do
    post local_path, params: { username: 'root', password: 'password' }
    follow_redirect!
    expect(request.fullpath).to eq(root_path)
    # Adjust according to new start-page
    expect(response.body).to match(/<div id='ember'><\/div>/)
  end

  it 'does not let root login via external ip' do
    expect_any_instance_of(Authentication::SourceIpChecker)
      .to receive(:private_ip?)
      .and_return(false)
    post local_path, params: { username: 'root', password: 'password' }
    expect(response).to have_http_status 401
    expect(response.body).to match(/You are not allowed to access this Page from your country/)
  end

  it 'does not let root login with wrong password' do
    post local_path, params: { username: 'bob', password: 'wrong_password' }
    follow_redirect!
    expect(request.fullpath).to eq(local_path)
    expect(response.body)
      .to match(/Authentication failed! Enter a correct username and password./)
  end

  xit 'lets root login with keycloak enabled' do
    enable_keycloak
    expect(Keycloak::Client).to receive(:user_signed_in?).and_return(false)
    post local_path, params: { username: 'root', password: 'password' }
    follow_redirect!
    expect(request.fullpath).to eq(root_path)
    # Adjust according to new start-page
    expect(response.body).to match(/<div id='ember'><\/div>/)
  end
end
