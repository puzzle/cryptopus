# frozen_string_literal: true

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

    def can_access_account(account_path, username, user_password = 'password',
                           account_username = 'account_username',
                           account_password = 'account_password')
      login_as(username, user_password)
      get account_path
      expect(response.body)
        .to match(/input .* id="cleartext_username" .* value="#{account_username}"/)
      expect(response.body)
        .to match(/input .* id="cleartext_password" .* value="#{account_password}"/)
      logout
    end

    def cannot_access_account(account_path, username, user_password = 'password')
      login_as(username, user_password)
      get account_path
      expect(flash[:error]).to match(/Access denied/)
      expect(response).to redirect_to teams_path
      logout
    end
  end
end
