require 'test_helper'
class UserLoginTest < ActionDispatch::IntegrationTest
include IntegrationTest::DefaultHelper
  test 'unlock user' do
    users(:bob).update_attribute(:locked, true)
    :post 
  end
end