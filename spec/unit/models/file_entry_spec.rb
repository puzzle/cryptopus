# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'
describe FileEntry do

  let(:bob) { users(:bob) }

  it 'does not upload same file twice in same credential' do
    params = {
      account_id: encryptables(:credentials1).id,
      file: file_entries(:file_entry1).file,
      filename: file_entries(:file_entry1).filename
    }
    file_entry = FileEntry.new(params)
    expect(file_entry).to_not be_valid
    expect('Filename is already taken').to eq(file_entry.errors.messages[:filename].first)
  end

  it 'can upload file to credential' do
    params = {
      account_id: encryptables(:credentials2).id,
      file: file_entries(:file_entry1).file,
      filename: file_entries(:file_entry1).filename
    }
    file_entry = FileEntry.new(params)
    expect(file_entry).to be_valid
  end

  it 'decrypts file_entry' do
    bobs_private_key = bob.decrypt_private_key('password')
    credential = encryptables(:credentials1)
    team = credential.folder.team
    cleartext_team_password = team.decrypt_team_password(bob, bobs_private_key)
    file_entry = credential.file_entries.first
    expect(file_entry.decrypt(cleartext_team_password)).to eq('Das ist ein test File')
  end

  it 'encrypts file_entry' do
    bobs_private_key = bob.decrypt_private_key('password')
    credential = encryptables(:credentials1)
    team = credential.folder.team
    cleartext_team_password = team.decrypt_team_password(bob, bobs_private_key)
    file_entry = FileEntry.new(account_id: credential.id, cleartext_file: 'Das ist ein test File',
                               filename: 'test', content_type: 'text')
    file_entry.encrypt(cleartext_team_password)
    file_entry.save!
    file_entry = FileEntry.find(file_entry.id)

    expect(file_entry.cleartext_file).to be_nil
    file_entry.decrypt(cleartext_team_password)
    expect(file_entry.cleartext_file).to eq('Das ist ein test File')
  end
end
