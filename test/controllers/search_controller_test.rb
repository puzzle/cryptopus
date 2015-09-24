require 'test_helper'
require 'test/unit'
require 'mocha/test_unit'

class SearchControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper
  test "should get account" do
    login_as(:bob)
    xhr :get, :account, {'search_string' => 'acc'}
    result_json = JSON.parse(response.body).first

    account = accounts(:account1)
    group = account.group
    team = group.team

    assert_equal account.accountname, result_json['accountname']
    assert_equal account.id, result_json['id']
    assert_equal 'test', result_json['username']
    assert_equal 'password', result_json['password']

    assert_equal group.name, result_json['group']
    assert_equal group.id, result_json['group_id']

    assert_equal team.name, result_json['team']
    assert_equal team.id, result_json['team_id']
  end
end
