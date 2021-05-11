# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'
describe MaintenanceTask do
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

  it 'creates new Log and rolls back db changes if exception was thrown' do
    mt = FailingTask.new
    mt.executer = users(:admin)

    expect do
      result = mt.execute
      expect(result).to be false
    end.to change { Account.count }.by(0)

    expect(Log.first.output).to eq('test')
    expect(Log.first.executer_id).to eq(mt.executer.id)
    expect(Log.first.status).to eq('failed')
  end

  it 'returns true if execute method succeeds' do
    mt = WorkingTask.new
    mt.executer = users(:admin)

    expect(mt.execute).to eq(true)
  end

  it 'creates new success log' do
    mt = WorkingTask.new
    mt.executer = users(:admin)
    mt.send(:success_log_entry, 'test')

    expect(Log.first.output).to eq('test')
    expect(Log.first.executer_id).to eq(mt.executer.id)
    expect(Log.first.status).to eq('success')
  end

  it 'saves changed data if no error occurs' do
    expect do
      mt = WorkingTask.new
      mt.executer = users(:admin)
      mt.execute
    end.to change { Account.count }.by(-1)
  end

  it 'lists all maintenance tasks' do
    enable_ldap
    list = MaintenanceTask.list

    expect(list.count).to eq(MaintenanceTask::TASKS.count)
  end
end
