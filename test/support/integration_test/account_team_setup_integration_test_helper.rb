module IntegrationTest
  module AccountTeamSetupHelper
    def create_team_group_account(username, user_password = 'password', noroot = false, private = false)
      login_as(username.to_s, user_password)

      #New Team
      post teams_path, team: {name: 'teamname', description: 'team_description', private: private, noroot: noroot}

      #New Group
      team_id = Team.find_by_name('teamname').id
      post team_groups_path(team_id: team_id), group: {name: 'groupname', description: 'group_description'}

      #New Account
      group_id = Group.find_by_name('groupname').id
      account_path = team_group_accounts_path(team_id: team_id, group_id: group_id)
      post account_path, account: {accountname: 'accountname', description: 'account_description', username: 'account_username', password: 'account_password'}

      logout
    end

    def create_team_group_account_noroot(username, user_password = 'password')
      create_team_group_account(username, user_password, true)
    end

    def create_team_group_account_private(username, user_password = 'password')
      create_team_group_account(username, user_password, false, true)
    end

    def create_team_group_account_private_noroot(username, user_password = 'password')
      create_team_group_account(username, user_password, true, true)
    end

    def create_team(user, teamname, private_team, noroot_team)
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
end