# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.
module SystemHelpers

  def login_as_user(username, password = 'password')
    visit(session_new_path)
    fill_in('username', with: username)
    fill_in('password', with: password)
    find('input[name="commit"]').click
    visit(search_path)
  end

  def login_as_root(username = 'root', password = 'password')
    visit('/session/local')
    fill_in('username', with: username)
    fill_in('password', with: password)
    find('input[name="commit"]').click
    visit('/search')
  end

  def logout
    find('a[data-method="get"][href="/session/destroy"]').click
  end
end
