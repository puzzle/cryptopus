# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe 'Reset DB user password' do
  include IntegrationHelpers::DefaultHelper

  it 'resets bobs password' do
    account = accounts(:account1)
    last_teammember_team = teams(:team2)
    login_as('admin')
    post resetpassword_admin_recryptrequests_path, params: { new_password: 'test',
                                                             user_id: users('bob').id },
                                                   headers: { 'HTTP_REFERER': 'where_i_came_from' }
    logout

    can_access_account(api_account_path(account.id), 'bob', 'test', 'test', 'password')
    expect(Team.exists?(last_teammember_team.id)).to eq false
  end
end
