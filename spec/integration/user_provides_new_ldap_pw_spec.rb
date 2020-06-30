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

      # Prepare for do
      bob.update!(auth: 'ldap', provider_uid: '42')

      # Method call expectations
      expect(LdapConnection).to receive(:new).at_least(:once).and_return(ldap)
      expect(ldap).to receive(:ldap_info).exactly(2).times

      expect(ldap).to receive(:authenticate!)
        .with('bob', 'newPassword')
        .exactly(4).times
        .and_return(true)

      # Calls login method
      # 2 times with login as and
      # 2 times in recryptrequests_controller

      login_as('bob', 'newPassword')
      expect(request.fullpath).to eq(recrypt_ldap_path)
      # Recrypt
      post recrypt_ldap_path, params: { new_password: 'newPassword',
                                        old_password: 'password' }

      follow_redirect!
      expect(request.fullpath).to eq(session_destroy_path)
      follow_redirect!
      expect(request.fullpath).to eq(session_new_path)

      #  do if Bob can see his account
      check_username_and_password
    end

    it 'provides new ldap password and doesnt remember his old password' do
      ldap = double

      # Prepare for  do
      bob.update!(auth: 'ldap', provider_uid: '42')

      # Method call expectations
      expect(LdapConnection).to receive(:new).at_least(:once).and_return(ldap)
      expect(ldap).to receive(:ldap_info).exactly(2).times

      expect(ldap).to receive(:authenticate!)
        .with('bob', 'newPassword')
        .exactly(3).times
        .and_return(true)

      # Calls login method
      # 2 times with login as and
      # 1 time in recryptrequests_controller

      login_as('bob', 'newPassword')
      expect(request.fullpath).to eq(recrypt_ldap_path)
      # Recrypt
      post recrypt_ldap_path, params: { forgot_password: true, new_password: 'newPassword' }

      follow_redirect!
      expect(request.fullpath).to eq(session_destroy_path)
      follow_redirect!
      expect(request.fullpath).to eq(session_new_path)

      login_as_root
      bobs_user_id = bob.id
      recrypt_id = Recryptrequest.find_by(user_id: bobs_user_id).id
      post admin_recryptrequest_path(recrypt_id), params: { _method: :delete }

      get session_destroy_path

      #  do if user could see his account(he should see now)
      check_username_and_password
    end

    it 'provides new ldap password and entered wrong old password' do
      ldap = double

      # Prepare for  do
      bob.update!(auth: 'ldap', provider_uid: '42')

      # Method call expectations
      expect(LdapConnection).to receive(:new).at_least(:once).and_return(ldap)

      expect(ldap).to receive(:authenticate!)
        .with('bob', 'newPassword')
        .exactly(3).times
        .and_return(true)

      # Calls login method
      # 2 times with login as and
      # 1 time in recryptrequests_controller

      login_as('bob', 'newPassword')
      expect(request.fullpath).to eq(recrypt_ldap_path)
      # Recrypt
      post recrypt_ldap_path, params: { new_password: 'newPassword',
                                        old_password: 'wrong_password' }

      follow_redirect!
      expect(request.fullpath).to eq(recrypt_ldap_path)

      #  do if user got error messages
      expect(flash[:error]).to match(/Your OLD password was wrong/)
    end

    it 'provides new ldap password and entered wrong new password' do
      ldap = double

      # Prepare for  do
      bob.update!(auth: 'ldap', provider_uid: '42')

      # Method call expectations
      expect(LdapConnection).to receive(:new).at_least(:twice).and_return(ldap)

      expect(ldap).to receive(:authenticate!)
        .with('bob', 'newPassword')
        .and_return(true)

      #  do if Bob can see his account (should not)
      # cannot_access_account(get_account_path, 'bob')

      login_as('bob', 'newPassword')

      # Recryptrecrypt_ldap_path

      expect(ldap).to receive(:authenticate!)
        .with('bob', 'wrong')
        .and_return(false)

      expect(request.fullpath).to eq(recrypt_ldap_path)

      post recrypt_ldap_path, params: { new_password: 'wrong' }
      follow_redirect!
      expect(request.fullpath).to eq(recrypt_ldap_path)
      #  do if user got error messages
      expect(flash[:error]).to match(/Your NEW password was wrong/)
    end

    it 'provides new ldap password over recryptrequest and entered wrong new password' do
      ldap = double

      # Prepare for  do
      bob.update!(auth: 'ldap', provider_uid: '42')

      # Method call expectations
      expect(LdapConnection).to receive(:new).exactly(2).times.and_return(ldap)

      expect(ldap).to receive(:authenticate!)
        .with('bob', 'newPassword')
        .and_return(true)

      #  do if Bob can see his account (should not)
      # cannot_access_account(get_account_path, 'bob')

      login_as('bob', 'newPassword')
      expect(request.fullpath).to eq(recrypt_ldap_path)

      # Recrypt
      expect(ldap).to receive(:authenticate!)
        .with('bob', 'wrong_password')
        .and_return(false)

      post recrypt_ldap_path, params: { forgot_password: true, new_password: 'wrong_password' }

      #  do if user got error messages
      expect(flash[:error]).to match(/Your NEW password was wrong/)
    end

  end

  private

  def check_username_and_password
    login_as('bob', 'newPassword')
    account = accounts(:account1)
    get api_account_path(account)

    data = JSON.parse(response.body)['data']['attributes']
    expect(data['cleartext_username']).to eq 'test'
    expect(data['cleartext_password']).to eq 'password'
  end

end
