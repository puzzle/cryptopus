# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class RootAsAdminTest < ActiveSupport::TestCase
  setup :disempower_root

  test 'non admin user cannot run task' do
    task = MaintenanceTask.find(1)
    task.executer = users(:bob)
    task.execute

    assert_match(/Only admin/, Log.first.output)
  end

  test 'current user private key' do
    task = MaintenanceTask.find(1)
    task.executer = users(:admin)
    task.param_values = { private_key: 'test' }

    assert_equal 'test', task.send(:current_user_private_key)
  end

  test 'does not toggle admin on root if root is already admin' do
    root = users(:root)
    params = {}
    params['root_password'] = 'password'

    task = MaintenanceTask.find(1)
    task.executer = users(:admin)
    task.param_values = params
    task.execute

    root.reload

    assert root.admin?, 'Root should be admin'
  end

  test 'adds admins to all root only teams' do
    admin = users(:admin)
    admin_private_key = CryptUtils.decrypt_private_key(admin.private_key, 'password')

    bob = users(:bob)
    bob.update_attributes(role: 2)
    teammembers(:team1_admin).destroy

    params = {}
    params[:private_key] = admin_private_key
    params['root_password'] = 'password'

    task = MaintenanceTask.find(1)
    task.executer = admin
    task.param_values = params

    non_private_team = Fabricate(:non_private_team)

    task.execute

    assert_equal true, non_private_team.teammember?(users(:root))
    assert_equal true, teams(:team1).teammember?(bob)
    assert_not teams(:team2).teammember?(admin)
    assert_not teams(:team2).teammember?(users(:root))
    assert User.root.admin
  end

  private

  def disempower_root
    users(:root).teammembers.joins(:team).where(teams: { private: false }).destroy_all
  end
end
