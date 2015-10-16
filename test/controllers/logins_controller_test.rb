require 'test_helper'
require 'test/unit'
require 'mocha/test_unit'

class LoginsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper
  test 'cannot login with wrong password' do
    post :authenticate, password: 'wrong_password', username: 'bob'
    assert_match /Authentication failed/, flash[:error]
  end

  test 'redirects to recryptrequests page if private key cannot be decrypted' do
      users(:bob).update(private_key: "wrong private_key")
      post :authenticate, password: 'password', username: 'bob'
      assert_redirected_to recryptrequests_path
  end

  test 'login logout' do
    login_as(:bob)
    get :logout
    assert_redirected_to login_login_path
  end

=begin
  test 'cannot login with unknown username' do
    #TODO test
  end
=end
end