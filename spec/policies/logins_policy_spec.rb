# frozen_string_literal: true

require 'rails_helper'

describe LoginsPolicy do
  include PolicyHelper

  context 'not yet logged in user' do
    it 'may login' do
      assert_permit nil, :logins, :login?
    end

    it 'may authenticate' do
      assert_permit nil, :logins, :authenticate?
    end

    it 'may not logout' do
      refute_permit nil, :logins, :logout?
    end

    it 'may not change locale' do
      refute_permit nil, :logins, :changelocale?
    end

    it 'may not update password' do
      refute_permit nil, :logins, :update_password?
    end

    it 'may not show update password form' do
      refute_permit nil, :logins, :show_update_password?
    end
  end

  context 'already logged in user' do
    it 'may not login' do
      refute_permit bob, :logins, :login?
    end

    it 'may not authenticate' do
      refute_permit bob, :logins, :authenticate?
    end

    it 'may logout' do
      assert_permit bob, :logins, :logout?
    end

    it 'may change locale' do
      assert_permit bob, :logins, :changelocale?
    end

    it 'may update password' do
      assert_permit bob, :logins, :update_password?
    end

    it 'may show update password form' do
      assert_permit bob, :logins, :show_update_password?
    end
  end

  context 'ldap user' do
    it 'may not change password' do
      bob.update!(auth: 'ldap')
      refute_permit bob, :logins, :update_password?
    end

    it 'may not show change password form' do
      bob.update!(auth: 'ldap')
      refute_permit bob, :logins, :show_update_password?
    end
  end
end
