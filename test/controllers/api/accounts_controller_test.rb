# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::AccountsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper
  test 'should get account for matching accountname without cleartext username / password' do
    login_as(:alice)
    get :index, params: {'q': 'acc'}, xhr: true

    result_json = JSON.parse(response.body)['data']['accounts'][0]

    account = accounts(:account1)
    group = account.group
    team = group.team

    assert_equal account.accountname, result_json['accountname']
    assert_equal account.id, result_json['id']
    assert_nil result_json['cleartext_username']
    assert_nil result_json['cleartext_password']

    assert_equal group.name, result_json['group']
    assert_equal group.id, result_json['group_id']

    assert_equal team.name, result_json['team']
    assert_equal team.id, result_json['team_id']
  end
  
  test 'should get empty json for no query' do
    login_as(:alice)
    get :index, params: {'q': ''}, xhr: true

    empty_json = JSON.parse(response.body)['data']
    
    assert_nil empty_json
  end

  test 'should get account for matching description without cleartext username / password' do
    login_as(:alice)
    get :index, params: {'q': 'des'}, xhr: true

    result_json = JSON.parse(response.body)['data']['accounts'][0]

    account = accounts(:account1)
    group = account.group
    team = group.team

    assert_equal account.accountname, result_json['accountname']
    assert_equal account.id, result_json['id']
    assert_nil result_json['cleartext_username']
    assert_nil result_json['cleartext_password']

    assert_equal group.name, result_json['group']
    assert_equal group.id, result_json['group_id']

    assert_equal team.name, result_json['team']
    assert_equal team.id, result_json['team_id']
  end
  
  test 'should get account for matching tag without cleartext username / password' do
    login_as(:bob)
    get :index, params: {'tag': 'tag'}, xhr: true

    result_json = JSON.parse(response.body)['data']['accounts'][0]

    account = accounts(:account2)
    group = account.group
    team = group.team

    assert_equal account.accountname, result_json['accountname']
    assert_equal account.id, result_json['id']
    assert_nil result_json['cleartext_username']
    assert_nil result_json['cleartext_password']

    assert_equal group.name, result_json['group']
    assert_equal group.id, result_json['group_id']

    assert_equal team.name, result_json['team']
    assert_equal team.id, result_json['team_id']
  end
end
