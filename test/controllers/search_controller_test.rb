require 'test_helper'
require 'test/unit'
require 'mocha/test_unit'
require 'pry'

class SearchControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper
  test "should get account" do
    login_as('bob')
    result = xhr :get, :account, {'search_string' => 'acc'}
    assert_include result.body, accounts(:account1).accountname
  end
end
