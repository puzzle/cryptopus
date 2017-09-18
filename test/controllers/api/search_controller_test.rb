# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::SearchControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper
  test "should get account for matching accountname without cleartext username / password" do
    login_as(:alice)
    get :accounts, params: {'q' => 'acc'}, xhr: true

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

  test "should get account for matching description without cleartext username / password" do
    login_as(:alice)
    get :accounts, params: {'q' => 'des'}, xhr: true

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

  test "should get group for search term" do
    login_as(:alice)
    get :groups, params: {'q' => 'group'}, xhr: true

    result_json = JSON.parse(response.body)['data']['groups'][0]

    group = groups(:group1)

    assert_equal group.name, result_json['name']
    assert_equal group.id, result_json['id']
  end


  test "should get team for search term" do
    login_as(:alice)
    get :teams, params: {'q' => 'team'}, xhr: true

    result_json = JSON.parse(response.body)['data']['teams'][0]

    team = teams(:team1)

    assert_equal team.name, result_json['name']
    assert_equal team.id, result_json['id']
  end
end
