require 'test_helper'

class AccountSerializerTest < ActiveSupport::TestCase
  test 'account to json' do
    account = accounts(:account1)
    account.cleartext_username = 'username'
    account.cleartext_password = 'password'

    as_json = JSON.parse(AccountSerializer.new(account).to_json)
    
    attrs = ['accountname', 'id', 'cleartext_password',
             'cleartext_username', 'group',
             'group_id', 'team', 'team_id']

    attrs.each { |attr|
      assert_includes as_json, attr
    }

    assert_not as_json.include? 'description'
    assert_not as_json.include? 'updated_at'
    assert_not as_json.include? 'created_at'
    assert_not as_json.include? 'username'
    assert_not as_json.include? 'password'
  end 
end
