module AccountTeamSetup
  def create_team_group_account(username, user_password, noroot = false, private = false)
    login_as(username, user_password)
    #New Team
    post "/teams", team: {name: 'teamname', description: 'team_description', private: private, noroot: noroot}
    #New Group
    team_id = Team.find_by_name('teamname').id
    group_link = "/teams/" + team_id.to_s + "/groups"
    post group_link, group: {name: 'groupname', description: 'group_description'}
    #New Account
    group_id = Group.find_by_name('groupname').id
    account_link = group_link + "/" + group_id.to_s + "/accounts"
    post account_link, account: {accountname: 'accountname', description: 'account_description', username: 'account_username', password: 'account_password'}
    logout
  end

  def create_team_group_account_noroot(username, user_password)
    create_team_group_account(username, user_password, true)
  end

  def create_team_group_account_private(username, user_password)
    create_team_group_account(username, user_password, false, true)
  end

  def create_team_group_account_private_noroot(username, user_password)
    create_team_group_account(username, user_password, true, true)
  end

  def create_team(user, teamname, private_team, noroot_team)
    require 'pry';binding.pry
    team = Team.create(name: teamname, description: 'team_description', private: private_team, noroot: noroot_team)
    team_password = cipher.random_key()
    crypted_team_password = CryptUtils.encrypt_blob user.public_key, team_password
    Teammember.attr_accessible :team_id, :password
    Teammember.create(team_id: team.id, password: crypted_team_password )
  end

  def create_group(team, groupname)
    Group.create(team_id: team.id, name: groupname, description: 'group_description')
  end

  def create_account(group, groupname, accountname)
    Account.create(group_id: group.id,accountname: accountname, description: 'account_description', username: 'account_username', password: 'account_password')
  end
end
