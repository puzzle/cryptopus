require 'test_helper'
require 'test/unit'
require 'mocha/test_unit'

class WizardControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper
  test 'return flash message if passwords are not filled out' do
    User.delete_all
    post :apply, password: '', password_repeat: 'password'
    assert_match /fill/, flash[:error]
  end

  test 'return flash message if passwords do not match' do
    User.delete_all
    post :apply, password: 'password', password_repeat: 'other_password'
    assert_match /not match/, flash[:error]
  end

  test 'create root and redirect to users path' do
    User.delete_all
    post :apply, password: 'password', password_repeat: 'password'
    assert_redirected_to admin_users_path
    assert_not_nil User.find_by_username('root')
  end

  test 'cannot access wizard if users already exists' do
    post :apply, password: 'password', password_repeat: 'password'
    assert_redirected_to login_login_path
  end
end