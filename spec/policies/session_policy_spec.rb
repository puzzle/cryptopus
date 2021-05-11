# frozen_string_literal: true

require 'spec_helper'

describe SessionPolicy do
  include PolicyHelper

  context 'not yet logged in user' do
    it 'may login' do
      assert_permit nil, :session, :new?
    end

    it 'may authenticate' do
      assert_permit nil, :session, :create?
    end

    it 'may not logout' do
      refute_permit nil, :session, :destroy?
    end

    it 'may not change locale' do
      refute_permit nil, :session, :changelocale?
    end

    it 'may not update password' do
      refute_permit nil, :session, :update_password?
    end

    it 'may not show update password form' do
      refute_permit nil, :session, :show_update_password?
    end
  end

  context 'already logged in user' do
    it 'may not login' do
      refute_permit bob, :session, :new?
    end

    it 'may not authenticate' do
      refute_permit bob, :session, :create?
    end

    it 'may logout' do
      assert_permit bob, :session, :destroy?
    end

    it 'may change locale' do
      assert_permit bob, :session, :changelocale?
    end

    it 'may update password' do
      assert_permit bob, :session, :update_password?
    end

    it 'may show update password form' do
      assert_permit bob, :session, :show_update_password?
    end
  end

  context 'ldap user' do
    it 'may not change password' do
      bob.update!(auth: 'ldap')
      refute_permit bob, :session, :update_password?
    end

    it 'may not show change password form' do
      bob.update!(auth: 'ldap')
      refute_permit bob, :session, :show_update_password?
    end
  end
end
