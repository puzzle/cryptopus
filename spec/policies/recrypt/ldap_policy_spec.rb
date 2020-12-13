# frozen_string_literal: true

require 'rails_helper'

describe RecryptLdapPolicy do
  include PolicyHelper

  let(:ldap_user) do
    user = users(:bob)
    user.auth = 'ldap'
    user
  end

  context 'as non-ldap user' do
    it 'cannot set a new ldap password' do
      expect(bob).to_not be_ldap
      refute_permit bob, :recryptLdap, :new?
    end
  end

  context 'as ldap user' do
    it 'ldap user can set a new ldap password' do
      assert_permit ldap_user, :recryptLdap, :new?
    end
  end

  context 'everyone' do
    it 'can trigger a recrypt request' do
      assert_permit admin, :recryptLdap, :create?
      assert_permit bob, :recryptLdap, :create?
      assert_permit alice, :recryptLdap, :create?
    end
  end
end
