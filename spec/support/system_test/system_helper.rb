# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.
module SystemTest
  module SystemHelper

    def login_as_user(username, password = 'password')
      visit('/session/new')
      fill_in('username', with: username)
      fill_in('password', with: password)
      find('input[name="commit"]').click
      visit('/search')
    end

    def logout
      find('a[data-method="delete"][href="/session"]').click
    end
  end
end
