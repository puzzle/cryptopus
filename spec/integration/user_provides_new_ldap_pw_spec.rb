# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'User provides new Ldap Pw' do
  include IntegrationHelpers::AccountTeamSetupHelper
  include IntegrationHelpers::DefaultHelper

  before(:each) do
    enable_ldap
    mock_ldap_settings
  end

  let(:bob) { users(:bob) }

  context 'as bob' do
    it 'provides new ldap password and remembers old password' do
      ldap = double

      expect(GeoIp).to receive(:activated?).at_least(:once).and_return(false)

      # Prepare for do
      bob.update(auth: 'ldap')
      bob.update(provider_uid: '42')

      # Method call expectations
      expect(LdapConnection).to receive(:new).at_least(:once).and_return(ldap)
      expect(ldap).to receive(:ldap_info).exactly(4).times

      expect(ldap).to receive(:authenticate!)
        .with('bob', /newPassword|password/)
        .exactly(4).times
        .and_return(true)

      # Calls login method
      # 2 times with login as and
      # 2 times in recryptrequests_controller

      login_as('bob')

      # Recrypt
      post recryptrequests_recrypt_path, params: { new_password: 'newPassword',
                                                   old_password: 'password' }
      logout

      login_as('bob', 'newPassword')

      #  do if Bob can see his account
      account = accounts(:account1)
      get account_path(account)
      expect(response.body).to match(/input .* id='cleartext_username' .* value='test'/)
      expect(response.body).to match(/input .* id='cleartext_password' .* value='password'/)
    end

    it 'provides new ldap password and doesnt remember his old password' do
      ldap = double

      expect(GeoIp).to receive(:activated?).at_least(:once).and_return(false)
      # Prepare for  do
      bob.update!(auth: 'ldap')
      bob.update!(provider_uid: '42')

      # Method call expectations
      expect(LdapConnection).to receive(:new).at_least(:once).and_return(ldap)
      expect(ldap).to receive(:ldap_info).exactly(4).times

      expect(ldap).to receive(:authenticate!)
        .with('bob', /newPassword|password/)
        .exactly(3).times
        .and_return(true)

      # Calls login method
      # 2 times with login as and
      # 1 time in recryptrequests_controller

      login_as('bob')

      # Recrypt
      post recryptrequests_recrypt_path, params: { forgot_password: true,
                                                   new_password: 'newPassword' }

      get session_destroy_path

      login_as('admin')
      bobs_user_id = bob.id
      recrypt_id = Recryptrequest.find_by(user_id: bobs_user_id).id
      post admin_recryptrequest_path(recrypt_id), params: { _method: :delete }

      get session_destroy_path

      #  do if user could see his account(he should see now)
      login_as('bob', 'newPassword')
      account = accounts(:account1)
      get account_path(account)

      expect(response.body).to match(/input .* id='cleartext_username' .* value='test'/)
      expect(response.body).to match(/input .* id='cleartext_password' .* value='password'/)
    end

    it 'provides new ldap password and entered wrong old password' do
      ldap = double

      # Prepare for  do
      bob.update(auth: 'ldap')
      bob.update(provider_uid: '42')

      # Method call expectations
      expect(LdapConnection).to receive(:new).at_least(:once).and_return(ldap)
      expect(ldap).to receive(:ldap_info).exactly(2).times

      expect(ldap).to receive(:authenticate!)
        .with('bob', /newPassword|password/)
        .exactly(3).times
        .and_return(true)

      # Calls login method
      # 2 times with login as and
      # 1 time in recryptrequests_controller

      login_as('bob')

      # Recrypt
      post recryptrequests_recrypt_path, params: { new_password: 'newPassword',
                                                   old_password: 'wrong_password' }

      #  do if user got error messages
      expect(flash[:error]).to match(/Your OLD password was wrong/)
    end

    it 'provides new ldap password and entered wrong new password' do
      ldap = double

      # Prepare for  do
      bob.update(auth: 'ldap')
      bob.update(provider_uid: '42')

      # Method call expectations
      expect(LdapConnection).to receive(:new).at_least(:twice).and_return(ldap)
      expect(ldap).to receive(:ldap_info).exactly(2).times

      expect(ldap).to receive(:authenticate!)
        .with('bob', /newPassword|password/)
        .and_return(true)

      #  do if Bob can see his account (should not)
      # cannot_access_account(get_account_path, 'bob')

      login_as('bob')

      # Recrypt

      expect(ldap).to receive(:authenticate!)
        .with('bob', 'wrong_password')
        .and_return(false)

      post recryptrequests_recrypt_path, params: { new_password: 'wrong_password' }

      #  do if user got error messages
      expect(flash[:error]).to match(/Your NEW password was wrong/)
    end

    it 'provides new ldap password over recryptrequest and entered wrong new password' do
      ldap = double

      # Prepare for  do
      bob.update(auth: 'ldap')
      bob.update(provider_uid: '42')

      # Method call expectations
      expect(LdapConnection).to receive(:new).exactly(4).times.and_return(ldap)
      expect(ldap).to receive(:ldap_info)
        .exactly(:twice)

      expect(ldap).to receive(:authenticate!)
        .with('bob', 'password')
        .and_return(true)

      #  do if Bob can see his account (should not)
      # cannot_access_account(get_account_path, 'bob')

      login_as('bob')

      # Recrypt
      expect(ldap).to receive(:authenticate!)
        .with('bob', 'wrong_password')
        .and_return(false)

      post recryptrequests_recrypt_path, params: { forgot_password: true,
                                                   new_password: 'wrong_password' }

      #  do if user got error messages
      expect(flash[:error]).to match(/Your NEW password was wrong/)
    end

  end
end
