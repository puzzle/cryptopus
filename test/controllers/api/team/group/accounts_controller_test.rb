# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::Team::Group::AccountsControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  test 'return decrypted account' do
    login_as(:bob)
    team = teams(:team1)
    group = groups(:group1)
    account = accounts(:account1)

    get :show, params: { team_id: team, group_id: group, id: account }, xhr: true
    account = JSON.parse(response.body)['data']['account']

    assert_equal 'account1', account['accountname']
    assert_equal 'test', account['cleartext_username']
    assert_equal 'password', account['cleartext_password']
  end
end
