# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe AccountMoveHandler do

  let(:bob) { users(:bob) }

  it 'moves account to a group where accountname already exist' do
    account = accounts(:account1)
    private_key = decrypt_private_key(bob)
    target_group = groups(:group2)
    team_password = target_group.team.decrypt_team_password(bob, private_key)
    Fabricate(:account, group: target_group, team_password: team_password, accountname: 'account1')

    account_handler = AccountMoveHandler.new(account, private_key, bob)

    expect(account_handler.move(target_group)).to be_nil
  end

  it 'moves account to a group from another team' do
    account = accounts(:account2)
    private_key = decrypt_private_key(bob)
    new_group = groups(:group1)

    expect(groups(:group2).id).to eq(account.group_id)
    account_handler = AccountMoveHandler.new(account, private_key, bob)
    account_handler.move(new_group)
    account.reload

    expect(account.decrypt(new_group.team.decrypt_team_password(bob,
                                                                private_key))).to eq('password')
    expect(new_group.id).to eq(account.group_id)
  end

  it 'moves account with items to new team' do
    account = accounts(:account1)
    private_key = decrypt_private_key(bob)
    new_group = groups(:group2)
    new_team_password = new_group.team.decrypt_team_password(bob, private_key)

    account_handler = AccountMoveHandler.new(account, private_key, bob)
    account_handler.move(new_group)

    expect(account).to eq(items(:item2).account)
    expect(teams(:team2)).to eq(items(:item2).account.group.team)

    decrypted_file_item1 = items(:item1).decrypt(new_team_password)
    decrypted_file_item2 = items(:item2).decrypt(new_team_password)

    expect(decrypted_file_item1).to eq('Das ist ein test File')
    expect(decrypted_file_item2).to eq('Das ist ein test File')
  end

  it 'cannot move account to a team user is not a member of' do
    alice = users(:alice)
    private_key = decrypt_private_key(alice)
    account = accounts(:account1)
    new_group = groups(:group2)

    expect do
      account_handler = AccountMoveHandler.new(account, private_key, alice)
      account_handler.move(new_group)
    end.to raise_error('user is not member of new team')
  end

  it 'moves account to group from same team' do
    account = accounts(:account1)
    private_key = decrypt_private_key(bob)
    new_group = Fabricate(:group, name: 'group3', team_id: teams(:team1).id)

    account_handler = AccountMoveHandler.new(account, private_key, bob)
    account_handler.move(new_group)

    expect(account.decrypt(new_group.team.decrypt_team_password(bob,
                                                                private_key))).to eq('password')
    expect(account.group).to eq(new_group)
  end

  it 'moves is rolled back if account can not be moved' do
    account = accounts(:account1)
    team1 = teams(:team1)
    bobs_private_key = decrypt_private_key(bob)
    new_group = groups(:group2)
    item1 = items(:item1)
    item2 = items(:item2)

    expect(account).to receive(:save!)

    account_handler = AccountMoveHandler.new(account, bobs_private_key, bob)
    begin
      account_handler.move(new_group)
    rescue StandardError
      team1_password = team1.decrypt_team_password(bob, bobs_private_key)
      item1.reload.decrypt(team1_password)
      expect(item1.cleartext_file).to eq('Das ist ein test File')
      item2.reload.decrypt(team1_password)
      expect(item2.cleartext_file).to eq('Das ist ein test File')

      expect(account.reload.group.team).to eq(team1)
    end
  end
end
