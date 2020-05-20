# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe 'Ldap user login' do
  include IntegrationHelpers::DefaultHelper

  before(:each) do
    mock_ldap_settings
    enable_ldap
    user_bob = users(:bob)
    user_bob.update(auth: 'ldap')
    user_bob.update(provider_uid: '42')
  end

  it 'logins as ldap user' do
    ldap = double

    # Mock
    expect(LdapConnection).to receive(:new).at_least(:once).and_return(ldap)
    expect(ldap).to receive(:ldap_info).exactly(:twice)
    expect(ldap).to receive(:authenticate!)
      .with('bob', 'password')
      .and_return(true)

    # login
    login_as('bob')
    assert request.fullpath, search_path
  end

  it 'logins to ldap with wrong password' do
    expect_any_instance_of(LdapConnection).to receive(:authenticate!)
      .with('bob', 'wrong_password')
      .and_return(false)

    login_as('bob', 'wrong_password')
    expect(flash[:error]).to include('Authentication failed')
  end
end
