module IntegrationTest
  module DefaultHelper
    def login_as(username, password = 'password')
      post_via_redirect "/en/login/authenticate", username: username, password: password
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
      assert_select ("input#username"), {value: account_username}
      assert_select ("input#password"), {value: account_password}
      logout
    end

    def cannot_access_account(account_path, username, user_password = 'password')
      login_as(username)
      error = assert_raises(RuntimeError) { get account_path }
      assert_includes error.message, "no access"
      logout
    end
  end
end
