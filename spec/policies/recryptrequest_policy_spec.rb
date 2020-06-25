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
end
