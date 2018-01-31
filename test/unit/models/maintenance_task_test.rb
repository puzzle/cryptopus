# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class MaintenanceTaskTest < ActiveSupport::TestCase
  class FailingTask < MaintenanceTask
    def execute
      super do
        Account.first.destroy!
        raise 'test'
      end
    end
  end
  
  class WorkingTask < MaintenanceTask
    def execute
      super do
        Account.first.destroy!
      end
    end
  end

  test 'creates new Log and rolls back db changes if exception was thrown' do
    mt = FailingTask.new
    mt.executer = users(:admin)

    assert_difference('Account.count', 0) do
      result = mt.execute
      assert_not result
    end

    assert_equal 'test', Log.first.output
    assert_equal mt.executer.id, Log.first.executer_id
    assert_equal 'failed', Log.first.status
  end

  test 'return true if execute method succeeds' do
    mt = WorkingTask.new
    mt.executer = users(:admin)
    
    assert_equal true, mt.execute
  end

  test 'create new success log' do
    mt = WorkingTask.new
    mt.executer = users(:admin)
    mt.send(:success_log_entry, 'test')

    assert_equal 'test', Log.first.output
    assert_equal mt.executer.id, Log.first.executer_id
    assert_equal 'success', Log.first.status
  end

  test 'save changed data if no error occurs' do
    assert_difference('Account.count', -1) do
      mt = WorkingTask.new
      mt.executer = users(:admin)
      mt.execute
    end
  end

  test 'list all maintenance tasks' do
    enable_ldap
    list = MaintenanceTask.list

    assert_equal MaintenanceTasks::RootAsAdmin, list.first.class
    assert_equal MaintenanceTask::TASKS.count, list.count
  end
end
