# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class GroupTest < ActiveSupport::TestCase

test 'does not create group if name is empty' do
    params = {}
    params[:name] = ''
    params[:description] = 'foo foo'

    group = Group.new(params)

    assert_not group.valid?
    assert_match /Name/, group.errors.full_messages.first
  end
end
