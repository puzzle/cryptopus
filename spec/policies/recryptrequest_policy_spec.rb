# frozen_string_literal: true

require 'rails_helper'

describe RecryptrequestPolicy do
  include PolicyHelper

  let(:ldap_user) do
    user = users(:bob)
    user.auth = 'ldap'
    user
  end

  context 'as admin' do
    it 'can see all recryptrequests' do
      assert_permit admin, Recryptrequest, :index?
    end

    it 'can destroy a recryptrequest' do
      assert_permit admin, Recryptrequest, :destroy?
    end
  end

  context 'as conf_admin' do
    it 'cannot see pending recryptrequests' do
      refute_permit conf_admin, Recryptrequest, :index?
    end

    it 'can not destroy a recryptrequest' do
      assert_equal true, conf_admin.conf_admin?
      refute_permit conf_admin, Recryptrequest, :destroy?
    end
  end

  context 'as non-admin' do
    it 'cannot see pending recryptrequests' do
      refute_permit bob, Recryptrequest, :index?
    end

    it 'can not destroy a recryptrequest' do
      expect(bob).to_not be_admin
      refute_permit bob, Recryptrequest, :destroy?
    end
  end

  context 'as non-ldap user' do
    it 'cannot set a new ldap password' do
      expect(bob).to_not be_ldap
      refute_permit bob, Recryptrequest, :new_ldap_password?
    end
  end

  context 'as ldap user' do
    it 'ldap user can set a new ldap password' do
      assert_permit ldap_user, Recryptrequest, :new_ldap_password?
    end
  end

  context 'everyone' do
    it 'can trigger a recrypt request' do
      assert_permit admin, Recryptrequest, :recrypt?
      assert_permit bob, Recryptrequest, :recrypt?
      assert_permit alice, Recryptrequest, :recrypt?
    end
  end
end
