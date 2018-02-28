# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
require 'test/unit'

class Admin::TeamlistControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  context '#index' do

    test 'user cannot access admin teams' do
      login_as(:bob)

      get :index

      teamlist = assigns(:teams)

      assert_redirected_to teams_path
      assert_nil teamlist
    end
    
    test 'conf admin lists teams' do
      login_as(:tux)

      get :index

      teamlist = assigns(:teams)

      assert_equal 2, teamlist.size
      assert_equal true, teamlist.any? { |t| t.name == 'team1' }
      assert_equal true, teamlist.any? { |t| t.name == 'team2' }
    end

    test 'admin lists teams' do
      login_as(:admin)

      get :index

      teamlist = assigns(:teams)

      assert_equal 2, teamlist.size
      assert_equal true, teamlist.any? { |t| t.name == 'team1' }
      assert_equal true, teamlist.any? { |t| t.name == 'team2' }
    end

  end
end
