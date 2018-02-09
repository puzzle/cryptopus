require 'test_helper'

class PolicyTest < ActiveSupport::TestCase
  protected
  
  def assert_permit(user, record, action)
    msg = "User #{user.inspect} should be permitted to #{action} #{record}, but isn't permitted"
    assert Pundit.policy!(user, record).public_send(action), msg
  end

  def refute_permit(user, record, action)
    msg = "User #{user.inspect} should NOT be permitted to #{action} #{record}, but is permitted"
    refute Pundit.policy!(user, record).public_send(action), msg
  end

  def admin
    users(:admin)
  end

  def conf_admin
    users(:conf_admin)
  end

  def bob
    users(:bob)
  end

  def alice
    users(:alice)
  end

  def root
    users(:root)
  end

  def ldap_user
    ldap_user = Fabricate(:user)
    ldap_user.auth = 'ldap'
    ldap_user
  end
end
