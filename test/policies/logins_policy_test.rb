require 'test_helper'

class LoginsPolicyTest < PolicyTest 

  context '#login' do

    test 'not yet logged in user may login' do
      assert_permit nil, :logins, :login?
    end

    test 'already logged in user may not login' do
      refute_permit bob, :logins, :login?
    end

  end

  context '#authenticate' do

    test 'not yet logged in user may authenticate' do
      assert_permit nil, :logins, :authenticate?
    end

    test 'already logged in user may not authenticate' do
      refute_permit bob, :logins, :authenticate?
    end

  end

  context '#logout' do

    test 'not yet logged may not logout' do
      refute_permit nil, :logins, :logout?
    end

    test 'already logged in user may logout' do
      assert_permit bob, :logins, :logout?
    end

  end

  context '#changelocale' do

    test 'not yet logged may not change locale' do
      refute_permit nil, :logins, :changelocale?
    end

    test 'already logged in user may change locale' do
      assert_permit bob, :logins, :changelocale?
    end

  end

  context '#update_password' do

    test 'not yet logged may not update password' do
      refute_permit nil, :logins, :update_password?
    end

    test 'already logged in user may update password' do
      assert_permit bob, :logins, :update_password?
    end

    test 'ldap user may not change password' do
      bob.update!(auth: 'ldap')
      refute_permit bob, :logins, :update_password?
    end

  end

  context '#show_update_password' do

    test 'not yet logged may not show update password form' do
      refute_permit nil, :logins, :show_update_password?
    end

    test 'already logged in user may show update password form' do
      assert_permit bob, :logins, :show_update_password?
    end

    test 'ldap user may not show change password form' do
      bob.update!(auth: 'ldap')
      refute_permit bob, :logins, :show_update_password?
    end

  end

end
