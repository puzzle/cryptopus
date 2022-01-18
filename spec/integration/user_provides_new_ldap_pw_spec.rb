# frozen_string_literal: true

require 'spec_helper'

describe 'User provides new Ldap Pw' do
  include IntegrationHelpers::AccountTeamSetupHelper
  include IntegrationHelpers::DefaultHelper

  before(:each) do
    enable_ldap
  end

  let(:bob) { users(:bob) }

  context 'as bob' do
    it 'provides new ldap password and remembers old password' do
      ldap = double

      bob.update!(auth: 'ldap', provider_uid: '42')

      # Method call expectations
      expect(LdapConnection).to receive(:new).at_least(:once).and_return(ldap)
      expect(ldap).to receive(:ldap_info).exactly(2).times

      expect(ldap).to receive(:authenticate!)
        .with('bob', 'newPassword')
        .exactly(3).times
        .and_return(true)

      login_as('bob', 'newPassword')
      expect(request.fullpath).to eq(recrypt_ldap_path)

      # Recrypt
      post recrypt_ldap_path, params: { new_password: 'newPassword',
                                        old_password: 'password' }

      follow_redirect!
      expect(request.fullpath).to eq(session_destroy_path)
      follow_redirect!
      expect(request.fullpath).to eq(session_new_path)

      assert_successful_recrypt
    end

    it 'provides new ldap password and entered wrong old password' do
      ldap = double

      # Prepare for  do
      bob.update!(auth: 'ldap', provider_uid: '42')

      # Method call expectations
      expect(LdapConnection).to receive(:new).at_least(:once).and_return(ldap)

      expect(ldap).to receive(:authenticate!)
        .with('bob', 'newPassword')
        .exactly(2).times
        .and_return(true)

      login_as('bob', 'newPassword')
      expect(request.fullpath).to eq(recrypt_ldap_path)

      # Recrypt
      post recrypt_ldap_path, params: { new_password: 'newPassword',
                                        old_password: 'wrong_password' }

      follow_redirect!
      expect(request.fullpath).to eq(recrypt_ldap_path)

      expect(flash[:error]).to match(/Your OLD password was wrong/)
    end

    it 'provides new ldap password and entered wrong new password' do
      ldap = double

      bob.update!(auth: 'ldap', provider_uid: '42')

      # Method call expectations
      expect(LdapConnection).to receive(:new).at_least(:once).and_return(ldap)

      expect(ldap).to receive(:authenticate!)
        .with('bob', 'newPassword')
        .and_return(true)

      expect(ldap).to receive(:authenticate!)
        .with('bob', 'wrong')
        .and_return(false)

      login_as('bob', 'newPassword')

      expect(request.fullpath).to eq(recrypt_ldap_path)

      post recrypt_ldap_path, params: { new_password: 'wrong' }
      expect(request.fullpath).to eq(recrypt_ldap_path)

      expect(flash[:error]).to match(/Your NEW password was wrong/)
    end

  end

  private

  def assert_successful_recrypt
    login_as('bob', 'newPassword')
    credential = encryptables(:credentials1)
    get api_encryptable_path(credential)

    data = JSON.parse(response.body)['data']['attributes']
    expect(data['cleartext_username']).to eq 'test'
    expect(data['cleartext_password']).to eq 'password'
  end

end
