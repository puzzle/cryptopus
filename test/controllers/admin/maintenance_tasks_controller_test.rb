# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
require 'test/unit'

class Admin::MaintenanceTasksControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper
  test 'error message if execute fails' do
    task = MaintenanceTask.new(users(:admin))
    MaintenanceTask.stubs(:initialize_task).returns(task)
    task.stubs(:execute).returns(false)

    login_as(:admin)
    post :execute, params: { id: 0, task_params: {root_password: 'password'} }

    assert_match /Task failed/, flash[:error]
  end

  test 'notice if execute succeed' do
    task = MaintenanceTask.new(users(:admin))
    MaintenanceTask.stubs(:initialize_task).returns(task)
    task.stubs(:execute).returns(true)

    login_as(:admin)
    post :execute, params: { id: 0, task_params: {root_password: 'password'} }

    assert_match /successfully/, flash[:notice]
  end

  test 'prepares task from array' do
    login_as(:admin)
    get :prepare, params: { id: 0, task_params: {type: 'password', label: :root_password} }
    assert_equal MaintenanceTasks::RootAsAdmin, assigns(:maintenance_task)
  end

  test 'get all maintenance tasks' do
    login_as(:admin)
    get :index
    assert_equal MaintenanceTasks::RootAsAdmin, assigns(:maintenance_tasks).first
  end
end
