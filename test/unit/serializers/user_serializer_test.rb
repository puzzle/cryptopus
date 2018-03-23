# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class UserSerializerTest < ActiveSupport::TestCase
  test 'exports only users id and label as json' do
    as_json = JSON.parse(UserSerializer.new(users(:alice)).to_json)

    assert_equal 3, as_json.size
    assert_equal 'user', as_json['role']
    assert_equal 'Alice test', as_json['label']
    assert_equal users(:alice).id, as_json['id']
  end
end
