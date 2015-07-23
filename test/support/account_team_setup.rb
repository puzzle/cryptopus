module AccountTeamSetup
  def setup_team_acc(username, user_password,teamname, team_description, private_team, noroot_team, groupname, group_description, accountname, account_description, account_username, account_password)
    login_as(username, user_password)
    #New Team
    post "/teams", team: {name: teamname, description: team_description, private: private_team, noroot: noroot_team}
    #New Group
    team_id = Team.find_by_name(teamname).id
    group_link = "/teams/" + team_id.to_s + "/groups"
    post group_link, group: {name: groupname, description: group_description}
    #New Account
    group_id = Group.find_by_name(groupname).id
    account_link = group_link + "/" + group_id.to_s + "/accounts"
    post account_link, account: {accountname: accountname, description: account_description, username: account_username, password: account_password}
    logout
  end
end
