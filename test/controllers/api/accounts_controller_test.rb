# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::AccountsControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  context '#index' do

    test 'returns account with matching name' do

      login_as(:alice)

      get :index, params: { 'q': 'acc' }, xhr: true

      account1_json = JSON.parse(response.body)['data']['accounts'][0]

      account = accounts(:account1)
      group = account.group
      team = group.team

      assert_equal account.accountname, account1_json['accountname']
      assert_equal account.id, account1_json['id']
      assert_nil account1_json['cleartext_username']
      assert_nil account1_json['cleartext_password']

      assert_equal group.name, account1_json['group']
      assert_equal group.id, account1_json['group_id']

      assert_equal team.name, account1_json['team']
      assert_equal team.id, account1_json['team_id']

    end

    test 'returns all accounts if empty query param given' do

      login_as(:alice)

      get :index, params: { 'q': '' }, xhr: true

      account1_json = JSON.parse(response.body)['data']['accounts'][0]

      account = accounts(:account1)
      group = account.group
      team = group.team

      assert_equal account.accountname, account1_json['accountname']
      assert_equal account.id, account1_json['id']
      assert_nil account1_json['cleartext_username']
      assert_nil account1_json['cleartext_password']

      assert_equal group.name, account1_json['group']
      assert_equal group.id, account1_json['group_id']

      assert_equal team.name, account1_json['team']
      assert_equal team.id, account1_json['team_id']

    end

    test 'returns all accounts if no query param given' do

      login_as(:alice)

      get :index, xhr: true

      account1_json = JSON.parse(response.body)['data']['accounts'][0]

      account = accounts(:account1)
      group = account.group
      team = group.team

      assert_equal account.accountname, account1_json['accountname']
      assert_equal account.id, account1_json['id']
      assert_nil account1_json['cleartext_username']
      assert_nil account1_json['cleartext_password']

      assert_equal group.name, account1_json['group']
      assert_equal group.id, account1_json['group_id']

      assert_equal team.name, account1_json['team']
      assert_equal team.id, account1_json['team_id']

    end

    test 'returns account for matching description without cleartext username / password' do
      login_as(:alice)
      get :index, params: { 'q': 'des' }, xhr: true

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

    test 'returns account for matching tag without cleartext username / password' do
      login_as(:bob)
      get :index, params: { 'tag': 'www.example.com' }, xhr: true

      result_json = JSON.parse(response.body)['data']['account']

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
end
