# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::GroupsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper
  test 'should get group for search term' do
    login_as(:alice)
    get :index, params: {'q' => 'group'}, xhr: true

    result_json = JSON.parse(response.body)['data']['groups'][0]

    group = groups(:group1)

    assert_equal group.name, result_json['name']
    assert_equal group.id, result_json['id']
  end
end
