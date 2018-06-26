# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class RemovedLdapUsersTest < ActiveSupport::TestCase

  test 'task is unavailable if ldap is disabled' do
    task = MaintenanceTasks::RemovedLdapUsers.new

    assert_nil MaintenanceTask.find(3)
    assert_not task.enabled?
  end
  
  test 'task is available if ldap is enabled' do
    enable_ldap
    task = MaintenanceTask.find(3)

    assert_not_nil task
    assert task.enabled?
  end

  test 'non admin user cannot run task' do
    enable_ldap
    task = MaintenanceTask.find(3)
    task.executer = users(:bob)
    task.execute

    assert_match(/Only admin/, Log.first.output)
  end

  test 'raises if ldap connection failed' do
    enable_ldap
    task = MaintenanceTask.find(3)
    task.executer = users(:admin)
    task.execute

    assert_match(/No configured Ldap Server could be reached/, Log.first.output)
  end

  test 'returns removed ldap users' do
    enable_ldap

    bob = users(:bob)
    bob.update!(auth: 'ldap')
    alice = users(:alice)
    alice.update!(auth: 'ldap')

    
    LdapConnection.any_instance.expects(:test_connection)
      .returns(true)

    LdapConnection.any_instance.
      expects(:exists?).
      with('bob').
      returns(false)

    LdapConnection.any_instance.
      expects(:exists?).
      with('alice').
      returns(true)

    task = MaintenanceTask.find(3)
    task.executer = users(:admin)
    task.execute

    assert_match(/successful/, Log.first.output)
    assert_equal 'bob', task.removed_ldap_users.first.username
    assert_equal 1, task.removed_ldap_users.size
  end
  
  test 'no removed ldap users exists' do
    enable_ldap

    LdapConnection.any_instance.expects(:test_connection)
      .returns(true)

    task = MaintenanceTask.find(3)
    task.executer = users(:admin)
    task.execute

    assert_match(/successful/, Log.first.output)
    assert_equal [], task.removed_ldap_users
  end
  
  test 'conf admin can execute task' do
    enable_ldap

    LdapConnection.any_instance.expects(:test_connection)
      .returns(true)

    task = MaintenanceTask.find(3)
    task.executer = users(:conf_admin)
    task.execute

    assert_match(/successful/, Log.first.output)
    assert_equal [], task.removed_ldap_users
  end

  private

  def ldap_connection
    LdapConnection.new
  end

end
