# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'
describe Account do

  let(:bob) { users(:bob) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let(:account) { accounts(:account1) }
  let(:team) { teams(:team1) }

  it 'does not create second account in same folder' do
    params = {}
    params[:name] = 'account1'
    params[:folder_id] = folders(:folder1).id
    params[:type] = 'Account::Credentials'
    account = Account.new(params)
    expect(account).to_not be_valid
    expect(account.errors.keys).to eq([:name])
  end

  it 'creates second account' do
    params = {}
    params[:name] = 'account1'
    params[:folder_id] = folders(:folder2).id
    params[:type] = 'Account::Credentials'
    account = Account.new(params)
    expect(account).to be_valid
  end

  it 'decrypts username and password' do
    team_password = team.decrypt_team_password(bob, bobs_private_key)

    account.decrypt(team_password)

    expect(account.cleartext_username).to eq('test')
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
    params[:name] = ''
    params[:description] = 'foo foo'
    params[:type] = 'Account::Credentials'

    account = Account.new(params)

    account.encrypted_data[:password] = { data: 'foo', iv: nil }
    account.encrypted_data[:username] = { data: 'foo', iv: nil }

    expect(account).to_not be_valid
    expect(account.errors.full_messages.first).to match(/Name/)
  end
end
