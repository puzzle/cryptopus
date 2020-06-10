# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe AccountMoveHandler do

  let(:bob) { users(:bob) }

  it 'moves account to a folder where accountname already exist' do
    account = accounts(:account1)
    private_key = decrypt_private_key(bob)
    target_folder = folders(:folder2)
    team_password = target_folder.team.decrypt_team_password(bob, private_key)
    Fabricate(:account,
              folder: target_folder,
              team_password: team_password,
              accountname: 'account1')

    AccountMoveHandler.new(account, private_key, bob).move
    account.save!
    expect(account.folder).to eq folders(:folder1)
  end

  it 'moves account to a folder from another team' do
    account = accounts(:account2)
    private_key = decrypt_private_key(bob)
    new_folder = folders(:folder1)

    expect(folders(:folder2).id).to eq(account.folder_id)
    account.folder = new_folder
    AccountMoveHandler.new(account, private_key, bob).move
    account.save!

    expect(account.decrypt(new_folder.team.decrypt_team_password(bob,
                                                                 private_key))).to eq('password')
    expect(new_folder.id).to eq(account.folder_id)
  end

  it 'moves account with file_entries to new team' do
    account = accounts(:account1)
    private_key = decrypt_private_key(bob)
    new_folder = folders(:folder2)
    new_team_password = new_folder.team.decrypt_team_password(bob, private_key)

    account.folder = new_folder
    AccountMoveHandler.new(account, private_key, bob).move
    account.save!

    expect(account).to eq(file_entries(:file_entry2).account)
    expect(teams(:team2)).to eq(file_entries(:file_entry2).account.folder.team)

    decrypted_file_file_entry1 = file_entries(:file_entry1).decrypt(new_team_password)
    decrypted_file_file_entry2 = file_entries(:file_entry2).decrypt(new_team_password)

    expect(decrypted_file_file_entry1).to eq('Das ist ein test File')
    expect(decrypted_file_file_entry2).to eq('Das ist ein test File')
  end

  it 'cannot move account to a team user is not a member of' do
    alice = users(:alice)
    private_key = decrypt_private_key(alice)
    account = accounts(:account1)
    new_folder = folders(:folder2)

    account.folder = new_folder
    expect do
      AccountMoveHandler.new(account, private_key, alice).move
    end.to raise_error('user is not member of new team')
  end

  it 'moves account to folder from same team' do
    account = accounts(:account1)
    private_key = decrypt_private_key(bob)
    new_folder = Fabricate(:folder, name: 'folder3', team_id: teams(:team1).id)

    account.folder = new_folder
    AccountMoveHandler.new(account, private_key, bob).move
    account.save!


    decrypted = account.decrypt(new_folder.team.decrypt_team_password(bob, private_key))
    expect(decrypted).to eq('password')
    expect(account.folder).to eq(new_folder)
  end

  it 'moves is rolled back if account can not be moved' do
    account = accounts(:account1)
    team1 = teams(:team1)
    bobs_private_key = decrypt_private_key(bob)
    new_folder = folders(:folder2)
    file_entry1 = file_entries(:file_entry1)
    file_entry2 = file_entries(:file_entry2)

    account.folder = new_folder
    begin
      AccountMoveHandler.new(account, bobs_private_key, bob).move
    rescue StandardError
      team1_password = team1.decrypt_team_password(bob, bobs_private_key)
      file_entry1.reload.decrypt(team1_password)
      expect(file_entry1.cleartext_file).to eq('Das ist ein test File')
      file_entry2.reload.decrypt(team1_password)
      expect(file_entry2.cleartext_file).to eq('Das ist ein test File')

      expect(account.reload.folder.team).to eq(team1)
    end
  end
end
