require 'test_helper'
class AccountTest <  ActiveSupport::TestCase
  test 'account to json' do
    account = accounts(:account1)
    account['username'] = 'username'
    account['password'] = 'pasword'
    account_json = account.to_json


    ary = ['accountname', 'id', 'password', 'username', 'group', 'group_id', 'team', 'team_id']
    ary.each { |element|
      assert_includes account_json, element
    }

    assert_not account_json.include? 'description'
    assert_not account_json.include? 'updated_at'
    assert_not account_json.include? 'created_at'
  end
end