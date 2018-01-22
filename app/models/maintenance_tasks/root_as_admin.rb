# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class MaintenanceTasks::RootAsAdmin < MaintenanceTask
  self.id = 1
  self.label = 'Set root as admin'
  self.description = 'Sets the root as an admin and the root role will be removed.'
  self.task_params = [{ label: :root_password, type: PARAM_TYPE_PASSWORD }]

  def execute
    super do
      raise 'Only admins can run this Task' unless executer.admin?

      check_root_password
      empower_admins_in_root_teams
      unless User.root.admin?
        User.root.update_role(current_user, 2, current_user_private_key)
      end
    end
  end

  private

  def check_root_password
    raise 'Wrong root password' unless User.root.authenticate(root_password)
  end

  def empower_admins_in_root_teams
    root = User.root
    roots_plaintext_private_key = root.decrypt_private_key(root_password)
    root.teams.each do |t|
      add_admins_to_team(roots_plaintext_private_key, t)
    end
  end

  def root_password
    param_values['root_password']
  end

  def add_admins_to_team(roots_plaintext_private_key, team)
    plaintext_team_password = team.decrypt_team_password(User.root, roots_plaintext_private_key)
    User.admins.each do |u|
      next if team.teammember?(u)
      team.add_user(u, plaintext_team_password)
    end
    team.update_attributes(private: false)
  end

  def current_user_private_key
    param_values[:private_key]
  end

end
