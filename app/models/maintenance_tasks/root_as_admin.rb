class MaintenanceTasks::RootAsAdmin < MaintenanceTask
  self.label = 'Set root as admin'
  self.description = ''
  self.task_params = [{ label: :root_password, type: PARAM_TYPE_PASSWORD }]

  def execute
    super do
      raise 'Only admins can run this Task' unless @current_user.admin?

      check_root_password
      empower_admins_in_root_teams
      User.root.empower(@current_user, current_user_private_key)
    end
  end

  private

  def check_root_password
    raise 'Wrong root password' unless User.root.authenticate(root_password)
  end

  def empower_admins_in_root_teams
    root = User.root
    roots_plaintext_private_key = CryptUtils.decrypt_private_key(root.private_key, root_password)
    root.teams.each do |t|
      add_admins_to_team(roots_plaintext_private_key, t)
    end
  end

  def root_password
    @param_values['root_password']
  end

  def add_admins_to_team(roots_plaintext_private_key, team)
    plaintext_team_password = team.decrypt_team_password(User.root, roots_plaintext_private_key)
    User.admins.each do |u|
      next if team.teammember?(u)
      team.add_user(u, plaintext_team_password)
    end
    team.update_attributes(private: false)
  end
end