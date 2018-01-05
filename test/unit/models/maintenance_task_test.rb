# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class MaintenanceTaskTest < ActiveSupport::TestCase
  test 'creates new Log if exception was thrown' do
    admin = users(:admin)
    mt = MaintenanceTask.new(admin)
    result = mt.execute do
      raise 'test'
    end

    assert_not result
    assert_equal 'test', Log.first.output
    assert_equal admin.id, Log.first.executer_id
    assert_equal 'failed', Log.first.status
  end

  test 'return true if execute method doesnt fails' do
    mt = MaintenanceTask.new(users(:admin))
    assert mt.execute
  end

  test 'current user private key' do
    admin = users(:admin)
    mt = MaintenanceTask.new(admin, {private_key: 'test'})

    assert_equal 'test', mt.send(:current_user_private_key)
  end

  test 'create new success log' do
    admin = users(:admin)
    mt = MaintenanceTask.new(admin)
    mt.send(:success_log_entry, 'test')

    assert_equal 'test', Log.first.output
    assert_equal admin.id, Log.first.executer_id
    assert_equal 'success', Log.first.status
  end

  test 'rollback if exception was thrown' do
    mt = MaintenanceTask.new(users(:admin))
    assert_difference('Team.count', 0) do
      mt.execute do
        Team.all.destroy_all
        raise 'test'
      end
    end
  end

  test 'save changed data if no error occurs' do
    mt = MaintenanceTask.new(users(:admin))
    mt.execute do
      Team.all.destroy_all
    end

    assert_equal 0, Team.count
  end

  test 'list all maintenance tasks' do
    list = MaintenanceTask.list
    assert_equal MaintenanceTasks::RootAsAdmin, list.first
    assert_equal MaintenanceTask::TASKS.count, list.count
  end
end