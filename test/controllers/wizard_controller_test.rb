require 'test_helper'
require 'test/unit'
require 'mocha/test_unit'

class WizardControllerTest < ActionController::TestCase

  test 'display error if password fields empty' do
    User.delete_all
    post :apply, password: '', password_repeat: 'password'
    assert_match /Please provide an initial password for the root user/, flash[:error]
  end

  test 'display error if passwords do not match' do
    User.delete_all
    post :apply, password: 'password', password_repeat: 'other_password'
    assert_match /Passwords do not match/, flash[:error]
  end

  test 'creates initial setup and redirects to user admin page' do
    User.delete_all
    post :apply, password: 'password', password_repeat: 'password'
    assert_redirected_to admin_users_path
    assert_not_nil User.find_by_username('root')
  end

  test 'cannot access wizard if already set up' do
    post :apply, password: 'password', password_repeat: 'password'
    assert_redirected_to login_login_path

    get :index
    assert_redirected_to login_login_path
  end
end
