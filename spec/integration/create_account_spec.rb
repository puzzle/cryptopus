# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'Create account' do
  include IntegrationHelpers::DefaultHelper

  let(:team) { teams(:team1) }
  let(:group) { groups(:group1) }

  it 'creates new account as bob' do
    login_as('bob')

    accounts_path = accounts_path(params: { account: { accountname: 'e-mail',
                                                       cleartext_username: 'bob@test',
                                                       cleartext_password: 'alice33',
                                                       group_id: group.id } })

    post accounts_path
    follow_redirect!

    account = group.accounts.find_by(accountname: 'e-mail')
    expect(account).to_not be_nil

    get account_path(id: account.id)

    expect(response.body).to match(/input .* id='cleartext_username' .* value='bob@test'/)
    expect(response.body).to match(/input .* id='cleartext_password' .* value='alice33'/)
  end

  it 'reads account data as alice' do
    login_as('alice')

    account = accounts(:account1)

    get account_path(id: account.id)

    expect(response.body).to match(/input .* id='cleartext_username' .* value='test'/)
    expect(response.body).to match(/input .* id='cleartext_password' .* value='password'/)
  end
end
