# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module IntegrationTest
  module AccountTeamSetupHelper
    def create_team_group_account(username, user_password = 'password', private = false)
      login_as(username.to_s, user_password)

      #New Team
      post teams_path, params: { team: {name: 'Web', description: 'team_description', private: private} }

      #New Group
      team = Team.find_by_name('Web')
      post team_groups_path(team_id: team.id), params: { group: {name: 'Default', description: 'group_description'} }

      #New Account
      group = team.groups.find_by_name('Default')
      account_path = team_group_accounts_path(team_id: team.id, group_id: group.id)
      post account_path, params: { account: {accountname: 'puzzle', description: 'account_description', cleartext_username: 'account_username', cleartext_password: 'account_password'} }

      logout
      group.accounts.find_by_accountname('puzzle')
    end

    def create_team_group_account_private(username, user_password = 'password')
      create_team_group_account(username, user_password, true)
    end

    def create_team(user, teamname, private_team)
      team = Team.create(name: teamname, description: 'team_description', private: private_team)
      team_password = cipher.random_key()
      crypted_team_password = CryptUtils.encrypt_blob user.public_key, team_password
      Teammember.attr_accessible :team_id, :password
      Teammember.create(team_id: team.id, password: crypted_team_password )
    end

    def create_group(team, groupname)
      Group.create(team_id: team.id, name: groupname, description: 'group_description')
    end

    def create_account(group, groupname, accountname)
      Account.create(group_id: group.id,accountname: accountname, description: 'account_description', cleartext_username: 'account_username', cleartext_password: 'account_password')
    end
  end
end
