# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class AccountHandlerTest < ActiveSupport::TestCase

  test 'Move returns new team password' do
    account = accounts(:account1)
    bob = users(:bob)
    team2 = teams(:team2)
    private_key = decrypt_private_key(bob)


    new_group = Fabricate(:group, team: team2)
    account_handler = AccountHandler.new(account, new_group, private_key, bob.id)
    new_team_password = account_handler.move

    team_password = team2.decrypt_team_password(bob, private_key)

    assert_equal new_group, account.group
    assert_equal team_password, new_team_password
  end

end
