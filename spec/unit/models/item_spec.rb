# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe Item do

  let(:bob) { users(:bob) }

  it 'does not upload same file twice in same account' do
    params = {
      account_id: accounts(:account1).id,
      file: items(:item1).file,
      filename: items(:item1).filename
    }
    item = Item.new(params)
    expect(item).to_not be_valid
    expect('Filename is already taken').to eq(item.errors.messages[:filename].first)
  end

  it 'can upload file to account' do
    params = {
      account_id: accounts(:account2).id,
      file: items(:item1).file,
      filename: items(:item1).filename
    }
    item = Item.new(params)
    expect(item).to be_valid
  end

  it 'decrypts item' do
    bobs_private_key = bob.decrypt_private_key('password')
    account = accounts(:account1)
    team = account.group.team
    cleartext_team_password = team.decrypt_team_password(bob, bobs_private_key)
    item = account.items.first
    expect(item.decrypt(cleartext_team_password)).to eq('Das ist ein test File')
  end

  it 'encrypts item' do
    bobs_private_key = bob.decrypt_private_key('password')
    account = accounts(:account1)
    team = account.group.team
    cleartext_team_password = team.decrypt_team_password(bob, bobs_private_key)
    item = Item.new(account_id: account.id, cleartext_file: 'Das ist ein test File',
                    filename: 'test', content_type: 'text')
    item.encrypt(cleartext_team_password)
    item.save!
    item = Item.find(item.id)

    expect(item.cleartext_file).to be_nil
    item.decrypt(cleartext_team_password)
    expect(item.cleartext_file).to eq('Das ist ein test File')
  end
end
