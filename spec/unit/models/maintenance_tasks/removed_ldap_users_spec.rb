# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.
require 'spec_helper'
describe MaintenanceTasks::RemovedLdapUsers do

  let(:ldap_connection) { LdapConnection.new }

  context 'task' do
    it 'is unavailable if ldap is disabled' do
      task = MaintenanceTasks::RemovedLdapUsers.new

      expect(MaintenanceTask.find(3)).to be_nil
      expect(task).to_not be_enabled
    end

    it 'is available if ldap is enabled' do
      enable_ldap

      task = MaintenanceTask.find(3)

      expect(task).to_not be_nil
      expect(task).to be_enabled
    end
  end

  it 'cannot run task as non admin user' do
    enable_ldap

    task = MaintenanceTask.find(3)
    task.executer = users(:bob)
    task.execute

    expect(Log.first.output).to match(/Only admin/)
  end

  it 'raises if ldap connection failed' do
    enable_ldap

    task = MaintenanceTask.find(3)
    task.executer = users(:admin)
    task.execute

    expect(Log.first.output).to match(/No configured Ldap Server could be reached/)
  end

  it 'returns removed ldap users' do
    enable_ldap

    bob = users(:bob)
    bob.update!(auth: 'ldap')
    alice = users(:alice)
    alice.update!(auth: 'ldap')

    expect_any_instance_of(LdapConnection)
      .to receive(:test_connection)
      .and_return(true)
    expect_any_instance_of(LdapConnection)
      .to receive(:all_uids)
      .at_least(:once)
      .and_return(['alice'])

    task = MaintenanceTask.find(3)
    task.executer = users(:admin)
    task.execute

    expect(Log.first.output).to match(/successful/)
    expect(task.removed_ldap_users.first.username).to eq('bob')
    expect(task.removed_ldap_users.size).to eq(1)
  end

  it 'finds no removed ldap users' do
    enable_ldap

    expect_any_instance_of(LdapConnection).to receive(:test_connection).and_return(true)

    task = MaintenanceTask.find(3)
    task.executer = users(:admin)
    task.execute

    expect(Log.first.output).to match(/successful/)
    expect(task.removed_ldap_users).to eq([])
  end

  it 'can execute task as conf admin' do
    enable_ldap

    expect_any_instance_of(LdapConnection).to receive(:test_connection).and_return(true)

    task = MaintenanceTask.find(3)
    task.executer = users(:conf_admin)
    task.execute

    expect(Log.first.output).to match(/successful/)
    expect(task.removed_ldap_users).to eq([])
  end
end
