# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'
describe EncryptableMoveHandler do

  let(:bob) { users(:bob) }

  it 'moves credentials to a folder where credential name already exist' do
    credential = encryptables(:credentials1)
    private_key = decrypt_private_key(bob)
    target_folder = folders(:folder2)
    team_password = target_folder.team.decrypt_team_password(bob, private_key)
    Fabricate(:credential,
              folder: target_folder,
              team_password: team_password,
              name: 'credentials1')

    EncryptableMoveHandler.new(credential, private_key, bob).move
    credential.save!
    expect(credential.folder).to eq folders(:folder1)
  end

  it 'moves credential from team2 folder to team1 folder' do
    credential = encryptables(:credentials2)
    private_key = decrypt_private_key(bob)
    team1_folder = folders(:folder1)

    expect(folders(:folder2).id).to eq(credential.folder_id)

    # current username, password values are set by api/encryptable#update
    credential.cleartext_username = 'username'
    credential.cleartext_password = 'password'

    credential.folder_id = team1_folder.id
    EncryptableMoveHandler.new(credential, private_key, bob).move
    credential.save!

    credential.decrypt(team1_password)

    expect(credential.cleartext_username).to eq('username')
    expect(credential.cleartext_password).to eq('password')
    expect(credential.folder_id).to eq(team1_folder.id)
  end

  it 'moves credential with file entries to new team' do
    credentials1 = encryptables(:credentials1)
    private_key = decrypt_private_key(bob)
    new_folder = folders(:folder2)
    new_team_password = new_folder.team.decrypt_team_password(bob, private_key)
    file1 = encryptables(:file1)

    credentials1.folder = new_folder
    EncryptableMoveHandler.new(credentials1, private_key, bob).move
    credentials1.save!

    expect(file1).to eq(encryptables(:file1).encryptable_credential)
    expect(teams(:team2)).to eq(encryptables(:file1).encryptable_credential.folder.team)

    decrypted_file_file_entry1 = encryptables(:file1).decrypt(new_team_password)

    expect(decrypted_file_file_entry1).to eq('Dolorem odio id. Veniam sit eum. Earum et nesciunt. \
                                             Sed modi voluptatem. Maxime qui rerum. A fugit eos. \
                                             Magnam atque at. Velit quam dolores.')
  end

  it 'cannot move credential to a team user is not a member of' do
    alice = users(:alice)
    private_key = decrypt_private_key(alice)
    credential = encryptables(:credentials1)
    new_folder = folders(:folder2)

    credential.folder = new_folder
    expect do
      EncryptableMoveHandler.new(credential, private_key, alice).move
    end.to raise_error('user is not member of new team')
  end

  it 'moves credential to folder from same team' do
    credential = encryptables(:credentials1)
    private_key = decrypt_private_key(bob)
    new_folder = Fabricate(:folder, name: 'folder5', team_id: teams(:team1).id)

    credential.folder = new_folder
    EncryptableMoveHandler.new(credential, private_key, bob).move
    credential.save!


    decrypted = credential.decrypt(new_folder.team.decrypt_team_password(bob, private_key))
    expect(decrypted).to eq('password')
    expect(credential.folder).to eq(new_folder)
  end

  it 'moves is rolled back if credential can not be moved' do
    credentials1 = encryptables(:credentials1)
    team1 = teams(:team1)
    bobs_private_key = decrypt_private_key(bob)
    new_folder = folders(:folder2)
    file_entry1 = encryptables(:file1)

    credentials1.folder = new_folder
    begin
      EncryptableMoveHandler.new(credentials1, bobs_private_key, bob).move
    rescue StandardError
      file_entry1.reload.decrypt(team1_password)
      expect(file_entry1.cleartext_file).to eq('Dolorem odio id. Veniam sit eum. Earum et \
                                               nesciunt. Sed modi voluptatem. Maxime qui rerum. \
                                               A fugit eos. Magnam atque at. Velit quam dolores.')
      expect(credentials1.reload.folder.team).to eq(team1)
    end
  end
end
