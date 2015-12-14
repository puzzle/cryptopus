require 'test_helper'
class RemoveUserTest < ActionDispatch::IntegrationTest
include IntegrationTest::DefaultHelper
  test 'do not display remove button' do
    login_as('admin')
    get admin_users_path
    assert_select 'a[href="/en/admin/users/#{session[:user_id]}"]', false, "Delete button should not exist"
  end
end