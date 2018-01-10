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
        Team.all.destroy_all
        raise 'test'
      end
    end
  end
  
  class RunningTask < MaintenanceTask
    def execute
      super do
        Team.all.destroy_all
      end
    end
  end

  test 'creates new Log if exception was thrown' do
    mt = FailingTask.new
    mt.executer = users(:admin)
    result = mt.execute

    assert_not result
    assert_equal 'test', Log.first.output
    assert_equal mt.executer.id, Log.first.executer_id
    assert_equal 'failed', Log.first.status
  end

  test 'return true if execute method doesnt fails' do
    mt = RunningTask.new
    mt.executer = users(:admin)
    
    assert mt.execute
  end

  test 'create new success log' do
    mt = RunningTask.new
    mt.executer = users(:admin)
    mt.send(:success_log_entry, 'test')

    assert_equal 'test', Log.first.output
    assert_equal mt.executer.id, Log.first.executer_id
    assert_equal 'success', Log.first.status
  end

  test 'rollback if exception was thrown' do
    mt = FailingTask.new 
    mt.executer = users(:admin)

    assert_difference('Team.count', 0) do
      mt.execute
    end
  end

  test 'save changed data if no error occurs' do
    mt = RunningTask.new
    mt.executer = users(:admin)
    mt.execute

    assert_equal 0, Team.count
  end

  test 'list all maintenance tasks' do
    list = MaintenanceTask.list

    assert_equal MaintenanceTasks::RootAsAdmin, list.first.class
    assert_equal MaintenanceTask::TASKS.count, list.count
  end
end
