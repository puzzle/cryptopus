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

  def bob
    users(:bob)
  end
  
end
