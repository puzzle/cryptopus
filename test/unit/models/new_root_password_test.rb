# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class NewRootPasswordTest < ActiveSupport::TestCase

  test 'non admin user cannot run task' do
    task = MaintenanceTasks::NewRootPassword.new(users(:bob))
    task.execute
    assert_match(/Only admin/, Log.first.output)
  end
  
  test 'task fails if passwords do not match' do
    admin = users(:admin)
    params = {}
    params['new_root_password'] = 'test'
    params['retype_password'] = 'other password'
 
    task = MaintenanceTask.initialize_task(1, admin, params)
    task.execute

    assert_match(/Passwords do not match/, Log.first.output)
  end

  test 'adds admins to all root only teams and destroy private teams teammembers' do
    admin = users(:admin)
    admin_private_key = CryptUtils.decrypt_private_key(admin.private_key, 'password')

    params = {}
    params[:private_key] = admin_private_key
    params['new_root_password'] = 'new_password'
    params['retype_password'] = 'new_password'

    task = MaintenanceTask.initialize_task(1, admin, params)
    task.execute

    assert_equal true, User.root.authenticate('new_password')
    assert teams(:team1).teammember?(users(:root))
    assert_not teams(:team2).teammember?(users(:root))
  end

  test 'adds admins to all root only teams and destroy last teammember teams' do
    bob = users(:bob)
    bob_private_key =  CryptUtils.decrypt_private_key(bob.private_key, 'password')
    team2_password = teams(:team2).decrypt_team_password(bob, bob_private_key)
    teams(:team2).add_user(users(:root), team2_password)
    teammembers(:team2_bob).destroy

    admin = users(:admin)
    admin_private_key = CryptUtils.decrypt_private_key(admin.private_key, 'password')

    params = {}
    params[:private_key] = admin_private_key
    params['new_root_password'] = 'new_password'
    params['retype_password'] = 'new_password'

    task = MaintenanceTask.initialize_task(1, admin, params)
    task.execute

    assert_equal true, User.root.authenticate('new_password')
    assert teams(:team1).teammember?(users(:root))
    assert_not Team.find_by(name: 'team2')
  end
end
