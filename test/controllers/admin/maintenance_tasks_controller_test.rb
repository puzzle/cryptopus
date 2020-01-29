# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
require 'test/unit'

class Admin::MaintenanceTasksControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  setup do
    GeoIp.stubs(:activated?)
  end

  context '#index' do

    test 'index cannot be accessed by non-root' do
      login_as(:bob)

      get :index

      assert_redirected_to teams_path
    end

    test 'get all maintenance tasks' do
      login_as(:admin)

      get :index

      maintenance_tasks = assigns(:maintenance_tasks)

      assert_equal 1, maintenance_tasks.size
    end

  end

end
