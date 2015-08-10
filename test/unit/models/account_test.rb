require 'test_helper'
class AccountTest <  ActiveSupport::TestCase
  test 'account to json' do
    account = accounts(:account1)
    account_json = account.to_json

    assert_includes account_json, 'accountname'
    assert_includes account_json, 'id'
    assert_includes account_json, 'password'
    assert_includes account_json, 'username'
    assert_includes account_json, 'group'
    assert_includes account_json, 'group_id'
    assert_includes account_json, 'team'
    assert_includes account_json, 'team_id'

    assert_no_match /description/, account_json
    assert_no_match /updated_on/, account_json
    assert_no_match /created_on/, account_json
  end
end