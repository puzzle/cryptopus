# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module IntegrationTest
  module DefaultHelper
    def login_as(username, password = 'password')
      post authenticate_login_path, params: { username: username, password: password }
      follow_redirect!
    end

    def logout
      get '/login/logout'
    end

    def get_account_path
      team = teams(:team1)
      group = groups(:group1)
      account = accounts(:account1)
      team_group_account_path(team_id: team.id, group_id: group.id, id: account.id)
    end

    def can_access_account(account_path, username, user_password = 'password', account_username = 'account_username', account_password = 'account_password')
      login_as(username, user_password)
      get account_path
      assert_select ("input#cleartext_username"), {value: account_username}
      assert_select ("input#cleartext_password"), {value: account_password}
      logout
    end

    def cannot_access_account(account_path, username, user_password = 'password')
      login_as(username, user_password)
      get account_path
      assert_match /You are not member of this team/, flash[:error]
      assert_redirected_to teams_path
      logout
    end
  end
end
