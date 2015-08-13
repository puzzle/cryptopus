require 'test_helper'
class UserTest < ActiveSupport::TestCase
  test 'cannot create second user bob' do
    user = User.new(username: 'bob')
    assert_not user.valid?
    assert_equal [:username], user.errors.keys
  end
end
