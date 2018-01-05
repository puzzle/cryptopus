# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class GroupTest < ActiveSupport::TestCase

    test 'does not create second group in same team' do
      params = {}
      params[:name] = 'group1'
      params[:team_id] = teams(:team1).id

      group = Group.new(params)

    	assert_not group.valid?
    	assert_equal [:name], group.errors.keys
    end

    test 'create second group' do
      params = {}
      params[:name] = 'group1'
      params[:team_id] = teams(:team2).id
      group = Group.new(params)

    	assert group.valid?
    end

    test 'does not create group if name is empty' do
      params = {}
      params[:name] = ''
      params[:description] = 'foo foo'
      group = Group.new(params)

      assert_not group.valid?
      assert_match /Name/, group.errors.full_messages.first
    end
end
