# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class RootAsAdminTest < ActiveSupport::TestCase
  setup :disempower_root

  test 'non admin user cannot run task' do
    task = MaintenanceTasks::RootAsAdmin.new(users(:bob))
    task.execute
    assert_match /Only admin/, Log.first.output
  end

  test 'adds admins to all root only teams' do
    root = users(:root)
    root.update_attributes(admin: false)

    admin = users(:admin)
    admin_private_key = CryptUtils.decrypt_private_key(admin.private_key, 'password')

    team_password = teams(:team1).decrypt_team_password(admin, admin_private_key)
    teams(:team1).add_user(root, team_password)

    bob = users(:bob)
    bob.update_attributes(admin: true)
    teammembers(:team1_admin).destroy

    params = {}
    params[:private_key] = admin_private_key
    params['root_password'] = 'password'

    task = MaintenanceTask.initialize_task(0, admin, params)

    non_private_team = Fabricate(:non_private_team)

    #Execute maintenance task
    task.execute

    assert non_private_team.teammember?(users(:root))
    assert teams(:team1).teammember?(bob)
    assert_not teams(:team2).teammember?(admin)
    assert_not teams(:team2).teammember?(users(:root))

    assert User.root.admin
  end

  private

  def disempower_root
    users(:root).send(:disempower)
  end
end
