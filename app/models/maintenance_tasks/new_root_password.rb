# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class MaintenanceTasks::NewRootPassword < MaintenanceTask
  self.label = 'New root password'
  self.description = 'Sets a new root password.'
  self.hint = 'WARNING! If you reset the root-password, all private
               teams can no longer be accessed by root.'
  self.task_params = [{ label: :new_root_password, type: PARAM_TYPE_PASSWORD },
                      { label: :retype_password, type: PARAM_TYPE_PASSWORD }]

  def execute
    super do
      raise 'Only admins can run this Task' unless @current_user.admin?

      check_passwords
      reset_password
    end
  end

  private

  def reset_password
    admin = @current_user
    root = User.root

    root.password = CryptUtils.one_way_crypt(new_root_password)
    root.create_keypair new_root_password
    root.save
    recrypt_passwords(root, admin, @param_values[:private_key])
  end

  def check_passwords
    raise 'Passwords do not match' unless new_root_password == @param_values['retype_password']
  end

  def recrypt_passwords(root, admin, private_key)
    root.last_teammember_teams.destroy_all
    root.teammembers.in_private_teams.destroy_all

    root.teammembers.in_non_private_teams.each do |tm|
      tm.recrypt_team_password(root, admin, private_key)
    end
  end

  def new_root_password
    @param_values['new_root_password']
  end
end
