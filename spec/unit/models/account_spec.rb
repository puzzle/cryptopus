# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe Account do

  let(:bob) { users(:bob) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let(:account) { accounts(:account1) }
  let(:team) { teams(:team1) }

  it 'does not create second account in same group' do
    params = {}
    params[:accountname] = 'account1'
    params[:group_id] = groups(:group1).id
    account = Account.new(params)
    expect(account).to_not be_valid
    expect(account.errors.keys).to eq([:accountname])
  end

  it 'creates second account' do
    params = {}
    params[:accountname] = 'account1'
    params[:group_id] = groups(:group2).id
    account = Account.new(params)
    expect(account).to be_valid
  end

  it 'decrypts username and password' do
    team_password = team.decrypt_team_password(bob, bobs_private_key)

    account.decrypt(team_password)

    expect(account.cleartext_username).to eq('test')
    expect(account.cleartext_password).to eq('password')
  end

  it 'does not update password if blank' do
    team_password = team.decrypt_team_password(bob, bobs_private_key)

    account.cleartext_username = 'new'
    account.cleartext_password = ''


    account.encrypt(team_password)
    account.save!
    account.reload
    account.decrypt(team_password)

    expect(account.cleartext_username).to eq('new')
    expect(account.cleartext_password).to eq('password')
  end

  it 'updates password and username' do
    team_password = team.decrypt_team_password(bob, bobs_private_key)

    account.cleartext_username = 'new'
    account.cleartext_password = 'foo'

    account.encrypt(team_password)
    account.save!
    account.reload
    account.decrypt(team_password)

    expect(account.cleartext_username).to eq('new')
    expect(account.cleartext_password).to eq('foo')
  end

  it 'does not create account if name is empty' do
    params = {}
    params[:accountname] = ''
    params[:username] = 'foo'
    params[:password] = 'foo'
    params[:description] = 'foo foo'

    account = Account.new(params)

    expect(account).to_not be_valid
    expect(account.errors.full_messages.first).to match(/Accountname/)
  end
end
